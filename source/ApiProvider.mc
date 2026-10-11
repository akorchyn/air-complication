import Toybox.Lang;
(:background)
module ApiProvider {
    function providerUid(uid) { return uid==29 ? 9999 : uid; }
    function queries(provider, location as Dictionary) as Array {
        if (location["kind"].equals("oblast")) { return [0]; }
        var ids=[providerUid(location["uid"])];
        if (location["oblast"]>0) { ids.add(location["oblast"]); }
        if (location["raion"]>0) { ids.add(location["raion"]); }
        return ids;
    }
    function url(provider, query) {
        var base=provider==1 ? "https://api.ukrainealarm.com/api/v3/alerts" : "https://siren.pp.ua/api/v3/alerts";
        return query==0 ? base : base+"/"+query;
    }
    function headers(provider, token) as Dictionary {
        var h={"Accept"=>"application/json"};
        if (provider==1) { h["Authorization"]=token; }
        return h;
    }
    function canonicalUid(value) { var id=AlertLogic.uid(value);return id==9999 ? 29 : id; }
    function regionType(value) {
        if (!(value instanceof String)) { return null; }
        if (value.equals("State")) { return "oblast"; }
        if (value.equals("District")) { return "raion"; }
        if (value.equals("Community") || value.equals("CityOrVillage") || value.equals("CityDistrict")) { return "city"; }
        return null;
    }
    function parse(data, location as Dictionary, query) {
        if (!(data instanceof Array) || !location["valid"]) { return AlertLogic.UNKNOWN; }
        // A regional response must confirm the requested region; [] is NOT clear.
        if (query!=0 && data.size()!=1) { return AlertLogic.UNKNOWN; }
        var result=AlertLogic.NONE;var uncertain=false;
        for(var i=0;i<data.size();i++) {
            var region=data[i];
            if (!(region instanceof Dictionary)) { uncertain=true;continue; }
            var root=AlertLogic.uid(region["regionId"]);
            if (root==null || regionType(region["regionType"])==null || !(region["activeAlerts"] instanceof Array)) { uncertain=true;continue; }
            if (query!=0 && root!=query) { uncertain=true;continue; }
            var alerts=region["activeAlerts"] as Array;
            for(var j=0;j<alerts.size();j++) {
                var a=alerts[j];
                if (!(a instanceof Dictionary)) { uncertain=true;continue; }
                var id=canonicalUid(a["regionId"]);var kind=regionType(a["regionType"]);
                if (id==null || kind==null) { uncertain=true;continue; }
                var match=AlertLogic.applies({"location_uid"=>id,"location_type"=>kind},location);
                if (match==null) { uncertain=true;continue; }
                if (!match) { continue; }
                var type=a["type"];
                if (!(type instanceof String)) { uncertain=true;continue; }
                if (!type.equals("AIR")) {
                    if (!(type.equals("ARTILLERY") || type.equals("URBAN_FIGHTS") || type.equals("CHEMICAL") || type.equals("NUCLEAR") || type.equals("INFO") || type.equals("CUSTOM"))) { uncertain=true; }
                    continue;
                }
                var levels=a["activeAlertLevels"];
                if (!(levels instanceof Array) || levels.size()==0) { uncertain=true;continue; }
                for(var k=0;k<levels.size();k++) {
                    var level=levels[k];
                    if (!(level instanceof Dictionary) || !(level["alertLevel"] instanceof String)) { uncertain=true;continue; }
                    if (level["alertLevel"].equals("Red")) { result=AlertLogic.RED; }
                    else if (level["alertLevel"].equals("Yellow")) { if(result!=AlertLogic.RED) { result=AlertLogic.YELLOW; } }
                    else { uncertain=true; }
                }
            }
        }
        if (result==AlertLogic.RED) { return result; }
        return uncertain ? AlertLogic.UNKNOWN : result;
    }
}
