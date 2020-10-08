import Match from './Match';
import MatchOptions from './MatchOptions';
import * as Utils from './Utils';

function putNewWord(block, word, blockSize) {
    block.push(word);

    if (block.length > blockSize) {
        block.shift();
    }

    if (block.length !== blockSize) {
        return null;
    }

    return block.join('');
}

// Finds the longest match in given texts. It uses indexing with fixed granularity that is used to compare blocks of text.
export default class MatchFinder {
    constructor(oldWords, newWords, startInOld, endInOld, startInNew, endInNew, options) {
        this.oldWords = oldWords;
        this.newWords = newWords;
        this.startInOld = startInOld;
        this.endInOld = endInOld;
        this.startInNew = startInNew;
        this.endInNew = endInNew;
        this.options = options;
    }

    indexNewWords() {
        this.wordIndices = new Map();
        let block = [];
        for (let i = this.startInNew; i < this.endInNew; i++) {
            // if word is a tag, we should ignore attributes as attribute changes are not supported (yet)
            let word = this.normalizeForIndex(this.newWords[i]);
            let key = putNewWord(block, word, this.options.blockSize);

            if (key === null) {
                continue;
            }

            if (this.wordIndices.has(key)) {
                this.wordIndices.get(key).push(i);
            } else {
                this.wordIndices.set(key, [i]);
            }
        }
    }

    // Converts the word to index-friendly value so it can be compared with other similar words
    normalizeForIndex(word) {
        word = Utils.stripAnyAttributes(word);
        if (this.options.IgnoreWhiteSpaceDifferences && Utils.isWhiteSpace(word)) {
            return ' ';
        }

        return word;
    }

    findMatch() {
        this.indexNewWords();
        this.removeRepeatingWords();

        if (this.wordIndices.length === 0) {
            return null;
        }

        let bestMatchInOld = this.startInOld;
        let bestMatchInNew = this.startInNew;
        let bestMatchSize = 0;

        let matchLengthAt = new Map();
        const blockSize = this.options.blockSize;
        let block = [];

        for (let indexInOld = this.startInOld; indexInOld < this.endInOld; indexInOld++) {
            let word = this.normalizeForIndex(this.oldWords[indexInOld]);
            let index = putNewWord(block, word, blockSize);

            if (index === null) {
                continue;
            }

            let newMatchLengthAt = new Map();

            if (!this.wordIndices.has(index)) {
                matchLengthAt = newMatchLengthAt;
                continue;
            }

            for (let indexInNew of this.wordIndices.get(index)) {
                let newMatchLength = (matchLengthAt.has(indexInNew - 1) ? matchLengthAt.get(indexInNew - 1) : 0) + 1;
                newMatchLengthAt.set(indexInNew, newMatchLength);

                if (newMatchLength > bestMatchSize) {
                    bestMatchInOld = indexInOld - newMatchLength - blockSize + 2;
                    bestMatchInNew = indexInNew - newMatchLength - blockSize + 2;
                    bestMatchSize = newMatchLength;
                }
            }

            matchLengthAt = newMatchLengthAt;
        }

        return bestMatchSize !== 0 ? new Match(bestMatchInOld, bestMatchInNew, bestMatchSize + blockSize - 1) : null;
    }

    // This method removes words that occur too many times. This way it reduces total count of comparison operations
    // and as result the diff algoritm takes less time. But the side effect is that it may detect false differences of
    // the repeating words.
    removeRepeatingWords() {
        let threshold = this.newWords.length + this.options.repeatingWordsAccuracy;
        let repeatingWords = Array.from(this.wordIndices.entries()).filter(i => i[1].length > threshold).map(i => i[0]);
        for (let w of repeatingWords) {
            this.wordIndices.delete(w);
        }
    }
}