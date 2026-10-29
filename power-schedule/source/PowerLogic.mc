import Toybox.Lang;
(:background)
module PowerLogic {
    function valid(data, now) {
        if (!(data instanceof Dictionary) || data["schema"]!=1 || data["region"]!=PowerConfig.region() || data["dso"]!=PowerConfig.dso() ||
            !(data["group"] instanceof String) || !data["group"].equals(PowerConfig.group())) { return false; }
        if (!(data["checkedAt"] instanceof Number) || data["checkedAt"]<=0 || data["checkedAt"]>now+300 ||
            !(data["updatedAt"] instanceof Number) || data["updatedAt"]<=0 || data["updatedAt"]>data["checkedAt"]+300 ||
            !(data["updatedLabel"] instanceof String) || data["updatedLabel"].length()>20) { return false; }
        var days=data["days"];
        if (!(days instanceof Array) || days.size()<1 || days.size()>2) { return false; }
        var previous=0;
        for(var i=0;i<days.size();i++) {
            var day=days[i];
            if (!(day instanceof Array) || day.size()!=5 || !(day[0] instanceof String) || day[0].length()!=10) { return false; }
            if (!(day[1] instanceof Number) || !(day[2] instanceof Number) || day[1]<previous || day[2]-day[1]<82800 || day[2]-day[1]>90000 ||
                !(day[3] instanceof Number) || day[3]<0 || day[3]>4 || !(day[4] instanceof Array) || day[4].size()>64) { return false; }
            previous=day[2];var last=day[1];
            for(var j=0;j<day[4].size();j++) {
                var slot=day[4][j];
                if (!(slot instanceof Array) || slot.size()!=5) { return false; }
                for(var k=0;k<5;k++) { if (!(slot[k] instanceof Number)) { return false; } }
                if (slot[0]<last || slot[1]<=slot[0] || slot[1]>day[2] || (slot[2]!=0 && slot[2]!=1) || slot[3]<0 || slot[4]>1440 || slot[3]>=slot[4]) { return false; }
                last=slot[1];
            }
            if (day[3]>=2 && day[4].size()!=0) { return false; }
            if (day[3]==0 && (day[4].size()!=1 || day[4][0][2]!=0 || day[4][0][0]!=day[1] || day[4][0][1]!=day[2])) { return false; }
        }
        return true;
    }
    function clock(minutes) { if(minutes==1440) { minutes=0; }return (minutes/60).format("%02d")+":"+(minutes%60).format("%02d"); }
    function label(slot, dayEnd, ending) {
        var epoch=ending ? slot[1] : slot[0];var minute=ending ? slot[4] : slot[3];
        return (epoch>=dayEnd ? "T " : "")+clock(minute);
    }
    function empty(state) { return {"state"=>state,"value"=>state,"out"=>"N/A","back"=>"N/A","until"=>""}; }
    function summary(r as Dictionary, now) as Dictionary {
        if (!PowerConfig.ready()) { return empty("SETUP"); }
        var data=r["data"];
        if (!(data instanceof Dictionary) || !valid(data,now) || r["fetched"]<=0 || now<r["fetched"] || now<data["checkedAt"]) { return empty("N/A"); }
        if (now-data["checkedAt"]>=PowerConfig.stale() || now-r["fetched"]>=PowerConfig.stale()) { return empty("STALE"); }
        if (r["failed"] || (r["lease"]>0 && now>=r["lease"])) { return empty("N/A"); }
        var days=data["days"];var active=null;var slots=[];
        for(var i=0;i<days.size();i++) {
            var day=days[i];
            if (day[1]<=now && now<day[2]) { active=day; }
            if(day[3]<2) { for(var j=0;j<day[4].size();j++) { slots.add(day[4][j]); } }
        }
        if (active==null) { return empty("N/A"); }
        if (active[3]==2) { return empty("WAIT"); }
        if (active[3]==3) { return empty("EMERG"); }
        if (active[3]>=4) { return empty("N/A"); }
        var index=-1;
        for(var i=0;i<slots.size();i++) { if(slots[i][0]<=now && now<slots[i][1]) { index=i;break; } }
        if (index<0) { return empty("N/A"); }
        var off=slots[index][2]==1;var result=empty(off ? "OFF" : "ON");
        var next=-1;
        if(off) { next=index;result["out"]="NOW"; }
        else { for(var i=index+1;i<slots.size();i++) { if(slots[i][2]==1) { next=i;break; } } }
        result["back"]="--";if(!off) { result["out"]="--"; }
        if(next>=0) {
            if(!off) { result["out"]=label(slots[next],active[2],false); }
            // Merge touching outages, including across midnight; only advertise
            // restoration where a confirmed NotPlanned slot actually follows.
            var end=next;
            while(end+1<slots.size() && slots[end+1][0]==slots[end][1] && slots[end+1][2]==1) { end+=1; }
            if(end+1<slots.size() && slots[end+1][0]==slots[end][1] && slots[end+1][2]==0) { result["back"]=label(slots[end+1],active[2],false); }
        }
        result["until"]=off ? result["back"] : result["out"];
        if(!result["until"].equals("--")) { result["value"]=result["state"]+" "+result["until"]; }
        return result;
    }
    function backoff(code, failures) {
        if(code==401 || code==403) { return 3600; }
        var n=300;for(var i=1;i<failures && n<3600;i++) { n*=2; }
        if(code==429 && n<900) { n=900; }return n>3600 ? 3600 : n;
    }
}
