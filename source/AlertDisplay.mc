(:background)
module AlertDisplay {
    function value(state) {
        if (Config.displayMode()==0) { return AlertLogic.text(state); }
        if (state==AlertLogic.NONE) { return "🟢"; }
        if (state==AlertLogic.YELLOW) { return "🟡"; }
        if (state==AlertLogic.RED) { return "🔴"; }
        if (state==AlertLogic.STALE) { return "!"; }
        return "?";
    }
}
