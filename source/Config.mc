using Toybox.Application;
import Toybox.Lang;
(:background)
module Config {
    function number(key, fallback) {
        var v=Application.Properties.getValue(key);
        return v instanceof Number ? v : fallback;
    }
    function token() {
        var v=Application.Properties.getValue(provider()==1 ? "ukraineAlarmToken" : "apiToken");
        return v instanceof String ? v : "";
    }
    function interval() {
        var n=number("refreshMinutes",5);
        return (n==5 || n==10 || n==15 || n==30 || n==60) ? n*60 : 300;
    }
    function provider() { var p=number("apiProvider",0);return (p>=0 && p<=2) ? p : 0; }
    function providerName() { return ["alerts.in.ua","Ukraine Alarm","UA Siren"][provider()]; }
    function needsToken() { return provider()!=2; }
    function displayMode() { return number("displayMode",0)==1 ? 1 : 0; }
    function displayModeName() { return displayMode()==1 ? "Status dots" : "Text"; }
    function textLanguage() { return number("textLanguage",0)==1 ? 1 : 0; }
    function textLanguageName() { return textLanguage()==1 ? "Українська" : "English"; }
    function textCase() { var c=number("textCase",0);return (c>=0 && c<=2) ? c : 0; }
    function textCaseName() { return ["Default","UPPERCASE","lowercase"][textCase()]; }
    function staleSeconds() { var n=number("staleMinutes",10); return (n>=5 && n<=60) ? n*60 : 600; }
    function location() as Dictionary {
        var id=number("cityUid",31);
        if (id==0) { id=AlertLogic.uid(Application.Properties.getValue("customUid")); }
        if (id==null) { id=0; }
        var preset=LocationPresets.lookup(id);
        if (preset!=null) {
            if (preset["kind"].equals("oblast")) {
                var scope=Application.Storage.getValue("resolvedScope");
                if (scope instanceof Dictionary && scope["uid"]==id && scope["members"] instanceof String && scope["known"] instanceof String) { preset["members"]=scope["members"];preset["known"]=scope["known"]; }
                else { preset["valid"]=false; }
            }
            return preset;
        }
        var resolved=Application.Storage.getValue("customLocation");
        if (resolved instanceof Dictionary && resolved["uid"]==id) { return resolved; }
        return {"uid"=>id,"name"=>"Custom UID "+id,"label"=>"ALERT","kind"=>"city","oblast"=>0,"raion"=>0,"valid"=>false,"uaSupported"=>false};
    }
}
