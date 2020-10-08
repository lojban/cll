export default class Match {
    constructor(startInOld, startInNew, size) {
        this.startInOld = startInOld;
        this.startInNew = startInNew;
        this.size = size;
    }

    get endInOld() {
        return this.startInOld + this.size;
    }

    get endInNew() {
        return this.startInNew + this.size;
    }
};