import Mode from './Mode';
import * as Utils from './Utils';

function convertHtmlToListOfWords(text, blockExpressions) {
    let state = {
        mode: Mode.character,
        currentWord: [],
        words: []
    };

    let blockLocations = findBlocks(text, blockExpressions);

    let isBlockCheckRequired = !!blockLocations.size;
    let isGrouping = false;
    let groupingUntil = -1;

    for (let i = 0; i < text.length; i++) {
        var character = text[i];

        // Don't bother executing block checks if we don't have any blocks to check for!
        if (isBlockCheckRequired) {
            // Check if we have completed grouping a text sequence/block
            if (groupingUntil === index) {
                groupingUntil = -1;
                isGrouping = false;
            }

            // Check if we need to group the next text sequence/block
            let until = 0;
            if (blockLocations.has(index)) {
                until = blockLocations.get(index);
                isGrouping = true;
                groupingUntil = until;
            }

            // if we are grouping, then we don't care about what type of character we have, it's going to be treated as a word
            if (isGrouping) {
                state.currentWord.push(character);
                state.mode = Mode.character;
                continue;
            }
        }

        switch (state.mode) {
            case Mode.character:
                if (Utils.isStartOfTag(character)) {
                    addClearWordSwitchMode(state, '<', Mode.tag);
                } else if (Utils.isStartOfEntity(character)) {
                    addClearWordSwitchMode(state, character, Mode.entity);
                } else if (Utils.isWhiteSpace(character)) {
                    addClearWordSwitchMode(state, character, Mode.whitespace);
                } else if (Utils.isWord(character) &&
                    (state.currentWord.length === 0 || Utils.isWord(state.currentWord[state.currentWord.length - 1]))) {
                    state.currentWord.push(character);
                } else {
                    addClearWordSwitchMode(state, character, Mode.character);
                }

                break;

            case Mode.tag:
                if (Utils.isEndOfTag(character)) {
                    state.currentWord.push(character);
                    state.words.push(state.currentWord.join(''));

                    state.currentWord = [];
                    state.mode = Utils.isWhiteSpace(character) ? Mode.whitespace : Mode.character;
                } else {
                    state.currentWord.push(character);
                }

                break;

            case Mode.whitespace:
                if (Utils.isStartOfTag(character)) {
                    addClearWordSwitchMode(state, character, Mode.tag);
                } else if (Utils.isStartOfEntity(character)) {
                    addClearWordSwitchMode(state, character, Mode.entity);
                } else if (Utils.isWhiteSpace(character)) {
                    state.currentWord.push(character);
                } else {
                    addClearWordSwitchMode(state, character, Mode.character);
                }

                break;

            case Mode.entity:
                if (Utils.isStartOfTag(character)) {
                    addClearWordSwitchMode(state, character, Mode.tag);
                } else if (Utils.isWhiteSpace(character)) {
                    addClearWordSwitchMode(state, character, Mode.whitespace);
                } else if (Utils.isEndOfEntity(character)) {
                    let switchToNextMode = true;
                    if (state.currentWord.length !== 0) {
                        state.currentWord.push(character);
                        state.words.push(state.currentWord.join(''));

                        //join &nbsp; entity with last whitespace
                        if (state.words.length > 2 &&
                            Utils.isWhiteSpace(state.words[state.words.length - 2]) &&
                            Utils.isWhiteSpace(state.words[state.words.length - 1])) {
                            let w1 = state.words[state.words.length - 2];
                            let w2 = state.words[state.words.length - 1];
                            state.words.splice(state.words.length - 2, 2);
                            state.currentWord = [(w1 + w2).split()];
                            state.mode = Mode.whitespace;
                            switchToNextMode = false;
                        }
                    }

                    if (switchToNextMode) {
                        state.currentWord = [];
                        state.mode = Mode.character;
                    }
                } else if (Utils.isWord(character)) {
                    state.currentWord.push(character);
                } else {
                    addClearWordSwitchMode(state, character, Mode.character);
                }

                break;
        }
    }

    if (state.currentWord.length !== 0) {
        state.words.push(state.currentWord.join(''));
    }

    return state.words;
}

function addClearWordSwitchMode(state, character, mode) {
    if (state.currentWord.length !== 0) {
        state.words.push(state.currentWord.join(''));
    }

    state.currentWord = [character];
    state.mode = mode;
}

function findBlocks(text, blockExpressions) {
    let blockLocations = new Map();

    if (blockExpressions === null) {
        return blockLocations;
    }

    for (let exp of blockExpressions) {
        let m;
        while ((m = exp.exec(text)) !== null) {
            if (blockLocations.has(m.index)) {
                throw new Error("One or more block expressions result in a text sequence that overlaps. Current expression: " + exp.toString());
            }

            blockLocations.set(m.index, m.index + m[0].length);
        }
    }

    return blockLocations;
}

export { convertHtmlToListOfWords };
