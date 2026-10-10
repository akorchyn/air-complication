using Toybox.Application;
using Toybox.Complications;
import Toybox.Lang;
using Toybox.Time;
using Toybox.Background;
(:background)
module Cache {
    function empty(location as Dictionary) as Dictionary {
        return {"schema"=>2,"provider"=>Config.provider(),"uid"=>location["uid"],"oblast"=>location["oblast"],"raion"=>location["raion"],"state"=>AlertLogic.UNKNOWN,"success"=>0,"failed"=>true,"failures"=>0,"next"=>0,"lease"=>0,"request"=>0,"sequence"=>0,"modified"=>null,"error"=>"Refresh to obtain status"};
    }
    function load(location as Dictionary) as Dictionary {
        var r=Application.Storage.getValue("cache");
        if (!(r instanceof Dictionary) || !valid(r) || r["provider"]!=Config.provider() || r["uid"]!=location["uid"] || r["oblast"]!=location["oblast"] || r["raion"]!=location["raion"]) {
            r=empty(location);save(r);
        }
        return r;
    }
    function valid(r as Dictionary) {
        var numbers=["schema","provider","uid","oblast","raion","state","success","failures","next","lease","request","sequence"];
        for(var i=0;i<numbers.size();i++) { if (!(r[numbers[i]] instanceof Number)) { return false; } }
        return r["schema"]==2 && r["state"]>=0 && r["state"]<=3 && r["failed"] instanceof Boolean && r["error"] instanceof String;
    }
    function save(r as Dictionary) { Application.Storage.setValue("cache",r); }
    function publish(r as Dictionary, location as Dictionary, now) {
        var value=AlertDisplay.value(AlertLogic.visible(r,now,Config.staleSeconds()));
        // No TTL exists in this API. See README for delayed delivery limitation.
        Complications.updateComplication(0,{:value=>value,:shortLabel=>location["label"]});
    }
    function schedule(r as Dictionary, now) {
        var due=r["next"];
        var expiry=r["success"]+Config.staleSeconds();
        if (r["success"]>0 && expiry>now && (due<=now || expiry<due)) { due=expiry; }
        // A previously registered future event already satisfies Garmin's
        // interval rules. Keep its deadline when foreground opening/Refresh
        // is skipped instead of pushing it another five minutes into the future.
        var registered=Background.getTemporalEventRegisteredTime();
        if (registered instanceof Time.Moment && registered.value()==due && due>now) { return; }
        if (due<now+300) { due=now+300; }
        if (registered instanceof Time.Moment && registered.value()==due) { return; }
        Background.registerForTemporalEvent(new Time.Moment(due));
    }
    function canRequest(r as Dictionary, now, manual) {
        if (r["lease"]>now) { return false; }
        // Foreground and service share a persisted lease and one-request/minute floor.
        if (now-r["request"]<60 && now>=r["request"]) { return false; }
        if (r["failures"]>0 && r["next"]>now) { return false; }
        if (!manual && r["next"]>now) { return false; }
        return true;
    }
    function failure(r as Dictionary, code, now) {
        r["failed"]=true;r["lease"]=0;r["failures"]+=1;
        r["next"]=now+AlertLogic.backoff(code,r["failures"]);
        if (code==401) { r["error"]="401: Check API token"; }
        else if (code==403) { r["error"]="403: API access blocked"; }
        else if (code==429) { r["error"]="429: Rate limited"; }
        else if (code==-402 || code==-403) { r["error"]="Response exceeds memory"; }
        else if (code==-400) { r["error"]="Invalid API response"; }
        else if (code<0) { r["error"]="Phone/network unavailable"; }
        else { r["error"]="HTTP/response error "+code; }
    }
    function accept(r as Dictionary, code, data, location as Dictionary, now) {
        var value=AlertLogic.UNKNOWN;
        if (code==200) { value=AlertLogic.parse(data,location); }
        // We do not send conditional headers: makeWebRequest exposes no response
        // headers / Last-Modified. An unsolicited 304 cannot validate the cache.
        if (value==AlertLogic.UNKNOWN) { failure(r,code==200 ? -400 : code,now);return false; }
        success(r,value,now);return true;
    }
    function success(r as Dictionary, value, now) {
        r["state"]=value;r["success"]=now;r["failed"]=false;
        r["failures"]=0;r["lease"]=0;r["next"]=now+Config.interval();r["error"]="";
    }
}
