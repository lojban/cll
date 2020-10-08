export default class Operation {
    constructor(action, startInOld, endInOld, startInNew, endInNew) {
        this.action = action;
        this.startInOld = startInOld;
        this.endInOld = endInOld;
        this.startInNew = startInNew;
        this.endInNew = endInNew;
    }
}