import Toybox.Lang;

// Pure decision logic; shared by foreground, service and Run No Evil tests.
(:background)
module AlertLogic {
    const NONE = 0;
    const YELLOW = 1;
    const RED = 2;
    const UNKNOWN = 3;
    const STALE = 4;

    function text(state) {
        if (state == NONE) { return "CLEAR"; }
        if (state == YELLOW) { return "YELLOW"; }
        if (state == RED) { return "RED"; }
        if (state == STALE) { return "STALE"; }
        return "N/A";
    }

    function uid(value) {
        if (value instanceof Number) { return value > 0 ? value : null; }
        if (!(value instanceof String) || value.length() == 0 || value.length() > 7) { return null; }
        for (var i=0; i<value.length(); i++) {
            var c=value.substring(i,i+1);
            if ("0123456789".find(c) == null) { return null; }
        }
        var n=value.toNumber();
        return n > 0 ? n : null;
    }

    // Exact city/community, entire parent oblast, or entire parent raion.
    // Never match a sibling city solely via location_oblast_uid.
    function applies(a as Dictionary, location as Dictionary) {
        var id=uid(a["location_uid"]);
        if (id == null) { return null; }
        if (id == location["uid"]) { return true; }
        if (location["kind"] instanceof String && location["kind"].equals("oblast")) {
            var members=location["members"];
            if (!(members instanceof String)) { return null; }
            if (members.find("|"+id+"|")!=null) { return true; }
            if (id==31 || id==30 || id==1293 || id==564) { return false; }
            var parent=uid(a["location_oblast_uid"]);
            if (parent!=null) { return parent==location["uid"]; }
            var known=location["known"];
            if (!(known instanceof String) || id>=known.length() || known.substring(id,id+1).equals("0")) { return null; }
            return false;
        }
        var type=a["location_type"];
        if (!(type instanceof String)) { return null; }
        if (type.equals("oblast")) {
            return location["oblast"] != 0 && id == location["oblast"];
        }
        if (type.equals("raion")) {
            return location["raion"] != 0 && id == location["raion"];
        }
        if (type.equals("city") || type.equals("hromada")) { return false; }
        return null;
    }

    function visible(record as Dictionary, now, staleSeconds) {
        var last=record["success"];
        if (last <= 0 || now < last) { return UNKNOWN; }
        if (now-last >= staleSeconds) { return STALE; }
        if (record["failed"]) { return UNKNOWN; }
        // An expired nonzero lease means a request never completed. Keep the
        // previous state in storage, but do not display it as current anymore.
        if (record["lease"]>0 && now>=record["lease"]) { return UNKNOWN; }
        return record["state"];
    }

    function backoff(code, failures) {
        if (code == 401 || code == 403) { return 3600; }
        var seconds=300;
        for (var i=1; i<failures && seconds<3600; i++) { seconds*=2; }
        if (code == 429 && seconds<900) { seconds=900; }
        return seconds>3600 ? 3600 : seconds;
    }
}
