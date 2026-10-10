(:background)
module AlertDisplay {
    // Explicit Cyrillic variants avoid relying on ASCII-oriented case conversion.
    // Default preserves the existing English capitals and Ukrainian wording.
    function text(state) {
        var style=Config.textCase();
        if (Config.textLanguage()==1) {
            if (state==AlertLogic.NONE) { return style==1 ? "НЕМАЄ" : style==2 ? "немає" : "Немає"; }
            if (state==AlertLogic.YELLOW) { return style==1 ? "ЖОВТА" : style==2 ? "жовта" : "Жовта"; }
            if (state==AlertLogic.RED) { return style==1 ? "ЧЕРВОНА" : style==2 ? "червона" : "Червона"; }
            if (state==AlertLogic.STALE) { return style==1 ? "ЗАСТАР." : style==2 ? "застар." : "Застар."; }
            return style==1 ? "Н.Д." : "н.д.";
        }
        var value=AlertLogic.text(state);
        return style==2 ? value.toLower() : value;
    }
    function value(state) {
        if (Config.displayMode()==0) { return text(state); }
        if (state==AlertLogic.NONE) { return "🟢"; }
        if (state==AlertLogic.YELLOW) { return "🟡"; }
        if (state==AlertLogic.RED) { return "🔴"; }
        if (state==AlertLogic.STALE) { return "!"; }
        return "?";
    }
}
