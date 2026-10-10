using Toybox.Application;
import Toybox.Lang;
(:background)
module Config {
    function number(key, fallback) {
        var v=Application.Properties.getValue(key);
        return v instanceof Number ? v : fallback;
    }
    function token() {
        var v=Application.Properties.getValue("apiToken");
        return v instanceof String ? v : "";
    }
    function interval() {
        var n=number("refreshMinutes",5);
        return (n==5 || n==10 || n==15 || n==30 || n==60) ? n*60 : 300;
    }
    function staleSeconds() { var n=number("staleMinutes",10); return (n>=5 && n<=60) ? n*60 : 600; }
    function location() as Dictionary {
        var id=number("cityUid",31);
        if (id==0) { id=AlertLogic.uid(Application.Properties.getValue("customUid")); }
        if (id==null) { id=0; }
        if (id==31) { return {"uid"=>31,"name"=>"Kyiv","label"=>"KYIV","oblast"=>0,"raion"=>0,"valid"=>true}; }
        if (id==1293) { return {"uid"=>1293,"name"=>"Kharkiv","label"=>"KHARK","oblast"=>0,"raion"=>0,"valid"=>true}; }
        if (id==564) { return {"uid"=>564,"name"=>"Zaporizhzhia","label"=>"ZAPOR","oblast"=>0,"raion"=>0,"valid"=>true}; }
        if (id==845) { return {"uid"=>845,"name"=>"Lviv","label"=>"LVIV","oblast"=>27,"raion"=>90,"valid"=>true}; }
        if (id==964) { return {"uid"=>964,"name"=>"Odesa","label"=>"ODESA","oblast"=>18,"raion"=>104,"valid"=>true}; }
        if (id==332) { return {"uid"=>332,"name"=>"Dnipro","label"=>"DNIPR","oblast"=>9,"raion"=>44,"valid"=>true}; }
        var resolved=Application.Storage.getValue("customLocation");
        if (resolved instanceof Dictionary && resolved["uid"]==id) { return resolved; }
        return {"uid"=>id,"name"=>"Custom UID "+id,"label"=>"ALERT","oblast"=>0,"raion"=>0,"valid"=>false};
    }
}
