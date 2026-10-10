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

    function level(value) {
        if (value instanceof String) {
            if (value.equals("red")) { return RED; }
            if (value.equals("yellow")) { return YELLOW; }
        }
        return UNKNOWN;
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

    function parse(data, location as Dictionary) {
        if (!(data instanceof Dictionary) || !(data["alerts"] instanceof Array) || !location["valid"]) { return UNKNOWN; }
        var alerts=data["alerts"] as Array;
        var result=NONE;
        var uncertain=false;
        for (var i=0; i<alerts.size(); i++) {
            var a=alerts[i];
            if (!(a instanceof Dictionary)) { uncertain=true; continue; }
            var match=applies(a,location);
            if (match == null) { uncertain=true; continue; }
            if (!match) { continue; }
            var type=a["alert_type"];
            if (!(type instanceof String)) { uncertain=true; continue; }
            if (!type.equals("air_raid")) {
                if (!(type.equals("artillery_shelling") || type.equals("urban_fights") || type.equals("chemical") || type.equals("nuclear"))) { uncertain=true; }
                continue;
            }
            // active.json must not contain ended applicable air raids.
            if (a.hasKey("finished_at") && a["finished_at"] != null) { uncertain=true; continue; }
            var value=level(a["alert_level"]);
            if (value == UNKNOWN) { uncertain=true; }
            var threats=a["threats"];
            if (threats != null) {
                if (!(threats instanceof Array)) { uncertain=true; }
                else {
                    for (var j=0; j<threats.size(); j++) {
                        var threat=threats[j];
                        if (!(threat instanceof Dictionary)) { uncertain=true; continue; }
                        var threatLevel=level(threat["level"]);
                        if (threatLevel == UNKNOWN) { uncertain=true; }
                        else if (threatLevel == RED) { value=RED; }
                        else if (value == NONE) { value=YELLOW; }
                    }
                }
            }
            if (value == RED) { result=RED; }
            else if (value == YELLOW && result != RED) { result=YELLOW; }
        }
        // A known RED remains an actionable warning even if another row is bad.
        if (result == RED) { return RED; }
        return uncertain ? UNKNOWN : result;
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
