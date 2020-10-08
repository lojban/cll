import Action from './Action';
import Match from './Match';
import MatchFinder from './MatchFinder';
import Operation from './Operation';
import MatchOptions from './MatchOptions';
import * as WordSplitter from './WordSplitter';
import * as Utils from './Utils';

// This value defines balance between speed and memory utilization. The higher it is the faster it works and more memory consumes.
const MatchGranuarityMaximum = 4;

const specialCaseClosingTags = new Map([
    ['</strong>', 0],
    ['</em>', 0],
    ['</b>', 0],
    ['</i>', 0],
    ['</big>', 0],
    ['</small>', 0],
    ['</u>', 0],
    ['</sub>', 0],
    ['</strike>', 0],
    ['</s>', 0],
    ['</dfn>', 0],
]);

const specialCaseOpeningTagRegex = /<((strong)|(b)|(i)|(dfn)|(em)|(big)|(small)|(u)|(sub)|(sup)|(strike)|(s))[\>\s]+/ig;

class HtmlDiff {
    constructor(oldText, newText) {
        this.content = [];
        this.newText = newText;
        this.oldText = oldText;

        this.specialTagDiffStack = [];
        this.newWords = [];
        this.oldWords = [];
        this.matchGranularity = 0;
        this.blockExpressions = [];

        this.repeatingWordsAccuracy = 1.0;
        this.ignoreWhiteSpaceDifferences = false;
        this.orphanMatchThreshold = 0.0;
    }

    build() {
        if (this.oldText === this.newText) {
            return this.newText;
        }

        this.splitInputsIntoWords();

        this.matchGranularity = Math.min(MatchGranuarityMaximum, this.oldWords.length, this.newWords.length);
        let operations = this.operations();

        for (let item of operations) {
            this.performOperation(item);
        }

        return this.content.join('');
    }

    addBlockExpression(exp) {
        this.blockExpressions.push(exp);
    }

    splitInputsIntoWords() {
        this.oldWords = WordSplitter.convertHtmlToListOfWords(this.oldText, this.blockExpressions);

        //free memory, allow it for GC
        this.oldText = null;

        this.newWords = WordSplitter.convertHtmlToListOfWords(this.newText, this.blockExpressions);

        //free memory, allow it for GC
        this.newText = null;
    }

    performOperation(opp) {
        switch (opp.action) {
            case Action.equal:
                this.processEqualOperation(opp);
                break;
            case Action.delete:
                this.processDeleteOperation(opp, "diffdel");
                break;
            case Action.insert:
                this.processInsertOperation(opp, "diffins");
                break;
            case Action.none:
                break;
            case Action.replace:
                this.processReplaceOperation(opp);
                break;
        }
    }

    processReplaceOperation(opp) {
        this.processDeleteOperation(opp, "diffmod");
        this.processInsertOperation(opp, "diffmod");
    }

    processInsertOperation(opp, cssClass) {
        let text = this.newWords.filter((s, pos) => pos >= opp.startInNew && pos < opp.endInNew);
        this.insertTag("ins", cssClass, text);
    }

    processDeleteOperation(opp, cssClass) {
        let text = this.oldWords.filter((s, pos) => pos >= opp.startInOld && pos < opp.endInOld);
        this.insertTag("del", cssClass, text);
    }

    processEqualOperation(opp) {
        let result = this.newWords.filter((s, pos) => pos >= opp.startInNew && pos < opp.endInNew);
        this.content.push(result.join(''));
    }

    insertTag(tag, cssClass, words) {
        while (words.length) {
            let nonTags = this.extractConsecutiveWords(words, x => !Utils.isTag(x));

            let specialCaseTagInjection = '';
            let specialCaseTagInjectionIsbefore = false;

            if (nonTags.length !== 0) {
                let text = Utils.wrapText(nonTags.join(''), tag, cssClass);
                this.content.push(text);
            } else {
                if (specialCaseOpeningTagRegex.test(words[0])) {
                    let matchedTag = words[0].match(specialCaseOpeningTagRegex);
                    matchedTag = '<' + matchedTag[0].replace(/(<|>| )/g, '') + '>';
                    this.specialTagDiffStack.push(matchedTag);
                    specialCaseTagInjection = '<ins class="mod">';
                    if (tag === 'del') {
                        words.shift();

                        while (words.length > 0 && specialCaseOpeningTagRegex.test(words[0])) {
                            words.shift();
                        }
                    }
                } else if (specialCaseClosingTags.has(words[0])) {
                    let openingTag = this.specialTagDiffStack.length === 0 ? null : this.specialTagDiffStack.pop();

                    // If we didn't have an opening tag, and we don't have a match with the previous tag used 
                    if (openingTag === null || openingTag !== words[words.length-1].replace(/\//g, '')) {
                        //do nothing
                    } else {    
                        specialCaseTagInjection = '</ins>';
                        specialCaseTagInjectionIsbefore = true;
                    }

                    if (tag === 'del') {
                        words.shift();

                        while (words.length > 0 && specialCaseClosingTags.has(words[0])) {
                            words.shift();
                        }
                    }
                }


                if (words.length === 0 && specialCaseTagInjection.length === 0) {
                    break;
                }

                if (specialCaseTagInjectionIsbefore) {
                    this.content.push(specialCaseTagInjection + this.extractConsecutiveWords(words, Utils.isTag).join(''));
                } else {
                    this.content.push(this.extractConsecutiveWords(words, Utils.isTag).join('') + specialCaseTagInjection);
                }
            }
        }
    }

    extractConsecutiveWords(words, condition) {
        let indexOfFirstTag = null;

        for (let i = 0; i < words.length; i++) {
            let word = words[i];

            if (i === 0 && word === ' ') {
                words[i] = '&nbsp;';
            }

            if (!condition(word)) {
                indexOfFirstTag = i;
                break;
            }
        }

        if (indexOfFirstTag !== null) {
            let items = words.filter((s, pos) => pos >= 0 && pos < indexOfFirstTag);
            if (indexOfFirstTag > 0) {
                words.splice(0, indexOfFirstTag);
            }

            return items;
        } else {
            let items = words.filter((s, pos) => pos >= 0 && pos < words.length);
            words.splice(0, words.length);
            return items;
        }
    }

    operations() {
        let positionInOld = 0;
        let positionInNew = 0;
        let operations = [];

        let matches = this.matchingBlocks();
        matches.push(new Match(this.oldWords.length, this.newWords.length, 0));

        let matchesWithoutOrphans = this.removeOrphans(matches);

        for (let match of matchesWithoutOrphans) {
            let matchStartsAtCurrentPositionInOld = positionInOld === match.startInOld;
            let matchStartsAtCurrentPositionInNew = positionInNew === match.startInNew;

            let action;

            if (!matchStartsAtCurrentPositionInOld && !matchStartsAtCurrentPositionInNew) {
                action = Action.replace;
            } else if (matchStartsAtCurrentPositionInOld && !matchStartsAtCurrentPositionInNew) {
                action = Action.insert;
            } else if (!matchStartsAtCurrentPositionInOld) {
                action = Action.delete;
            } else {
                action = Action.none;
            }

            if (action !== Action.none) {
                operations.push(new Operation(action, positionInOld, match.startInOld, positionInNew, match.startInNew));
            }

            if (match.length !== 0) {
                operations.push(new Operation(Action.equal, match.startInOld, match.endInOld, match.startInNew, match.endInNew));
            }

            positionInOld = match.endInOld;
            positionInNew = match.endInNew;
        }

        return operations;
    }

    * removeOrphans(matches) {
        let prev = null;
        let curr = null;

        for (let next of matches) {
            if (curr === null) {
                prev = new Match(0, 0, 0);
                curr = next;
                continue;
            }

            if (prev.endInOld === curr.startInOld && prev.endInNew === curr.startInNew ||
                curr.endInOld === next.startInOld && curr.endInNew === next.startInNew) {
                yield curr;
                let tmp = prev = curr; // "let tmp" avoids babel traspiling error
                curr = next;
                continue;
            }

            let sumLength = (t, n) => t + n.length;

            let oldDistanceInChars = this.oldWords.slice(prev.endInOld, next.startInOld).reduce(sumLength, 0);
            let newDistanceInChars = this.newWords.slice(prev.endInNew, next.startInNew).reduce(sumLength, 0);
            let currMatchLengthInChars = this.newWords.slice(curr.startInNew, curr.endInNew).reduce(sumLength, 0);
            if (currMatchLengthInChars > Math.max(oldDistanceInChars, newDistanceInChars) * this.orphanMatchThreshold) {
                yield curr;
            }

            prev = curr;
            curr = next;
        }

        yield curr;
    }

    matchingBlocks() {
        let matchingBlocks = [];
        this.findMatchingBlocks(0, this.oldWords.length, 0, this.newWords.length, matchingBlocks);
        return matchingBlocks;
    }

    findMatchingBlocks(startInOld, endInOld, startInNew, endInNew, matchingBlocks) {
        let match = this.findMatch(startInOld, endInOld, startInNew, endInNew);

        if (match !== null) {
            if (startInOld < match.startInOld && startInNew < match.startInNew) {
                this.findMatchingBlocks(startInOld, match.startInOld, startInNew, match.startInNew, matchingBlocks);
            }

            matchingBlocks.push(match);

            if (match.endInOld < endInOld && match.endInNew < endInNew) {
                this.findMatchingBlocks(match.endInOld, endInOld, match.endInNew, endInNew, matchingBlocks);
            }
        }
    }

    findMatch(startInOld, endInOld, startInNew, endInNew) {
        for (let i = this.matchGranularity; i > 0; i--) {
            let options = new MatchOptions();
            options.blockSize = i;
            options.repeatingWordsAccuracy = this.repeatingWordsAccuracy;
            options.ignoreWhitespaceDifferences = this.ignoreWhiteSpaceDifferences;

            let finder = new MatchFinder(this.oldWords, this.newWords, startInOld, endInOld, startInNew, endInNew, options);
            let match = finder.findMatch();
            if (match !== null) {
                return match;
            }
        }

        return null;
    }
}

HtmlDiff.execute = function (oldText, newText) {
    return new HtmlDiff(oldText, newText).build();
};

export default HtmlDiff;
