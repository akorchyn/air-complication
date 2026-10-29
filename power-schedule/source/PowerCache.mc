using Toybox.Application;
using Toybox.Background;
using Toybox.Complications;
using Toybox.Time;
import Toybox.Lang;
(:background)
module PowerCache {
    function fresh() as Dictionary { return {"schema"=>1,"key"=>PowerConfig.key(),"data"=>null,"fetched"=>0,"failed"=>true,"failures"=>0,"next"=>0,"request"=>0,"lease"=>0,"sequence"=>0,"error"=>"Open to check schedule"}; }
    function load() as Dictionary {
        var cached=Application.Storage.getValue("powerCache");
        if(!(cached instanceof Dictionary)) { return fresh(); }
        var r=cached as Dictionary;var ok=r["schema"]==1 && r["key"] instanceof String && r["key"].equals(PowerConfig.key());
        if(ok) {
            var keys=["fetched","failures","next","request","lease","sequence"];
            for(var i=0;i<keys.size();i++) { if(!(r[keys[i]] instanceof Number)) { ok=false; } }
            ok=ok && r["failed"] instanceof Boolean && r["error"] instanceof String;
        }
        // Read-only so the same path is safe in the restricted glance context.
        if(!ok) { r=fresh(); }return r;
    }
    function save(r as Dictionary) { Application.Storage.setValue("powerCache",r); }
    function publish(r as Dictionary, now) {
        var s=PowerLogic.summary(r,now);
        Complications.updateComplication(0,{:value=>s["value"],:shortLabel=>"PLAN"});
        Complications.updateComplication(1,{:value=>s["out"],:shortLabel=>"OUT"});
        Complications.updateComplication(2,{:value=>s["back"],:shortLabel=>"BACK"});
    }
    function schedule(r as Dictionary, now) {
        if(!PowerConfig.ready()) { Background.deleteTemporalEvent();return; }
        var due=r["next"];
        if(due<=now) { due=now+PowerConfig.interval(); }
        var data=r["data"];
        if(data instanceof Dictionary && PowerLogic.valid(data,now)) {
            var expiry=data["checkedAt"]+PowerConfig.stale();if(expiry>now && expiry<due) { due=expiry; }
            var days=data["days"];
            for(var i=0;i<days.size();i++) {
                var day=days[i];if(day[2]>now && day[2]<due) { due=day[2]; }
                for(var j=0;j<day[4].size();j++) {
                    var slot=day[4][j];
                    if(slot[0]>now && slot[0]<due) { due=slot[0]; }
                    if(slot[1]>now && slot[1]<due) { due=slot[1]; }
                }
            }
        }
        var registered=Background.getTemporalEventRegisteredTime();
        if(registered instanceof Time.Moment && registered.value()==due && due>now) { return; }
        if(due<now+300) { due=now+300; }
        if(registered instanceof Time.Moment && registered.value()==due) { return; }
        Background.registerForTemporalEvent(new Time.Moment(due));
    }
    function fail(r as Dictionary, code, now) {
        r["failed"]=true;r["lease"]=0;r["failures"]+=1;r["next"]=now+PowerLogic.backoff(code,r["failures"]);
        r["error"]=code==401 || code==403 ? "Check adapter access/key" : code==429 ? "Rate limited; retry later" : code==-402 || code==-403 ? "Adapter response too large" : code==-400 ? "Invalid adapter response" : code<0 ? "Phone/network unavailable" : "Schedule unavailable ("+code+")";
    }
}
