using Toybox.Application;
import Toybox.Lang;
(:background)
module PowerConfig {
    function number(key, fallback) { var v=Application.Properties.getValue(key);return v instanceof Number ? v : fallback; }
    function string(key) { var v=Application.Properties.getValue(key);return v instanceof String ? v : ""; }
    function profile() { var p=number("profile",0);return p>=0 && p<3 ? p : 0; }
    function region() { return profile()==0 ? 25 : 3; }
    function dso() { return [902,301,303][profile()]; }
    function name() { return ["Kyiv / DTEK","Dnipro / DnEM","Dnipro / CEK"][profile()]; }
    function group() { return string("group"); }
    function base() {
        var url=string("adapterUrl");
        while(url.length()>0 && url.substring(url.length()-1,url.length()).equals("/")) { url=url.substring(0,url.length()-1); }
        return url;
    }
    function ready() {
        var selected=number("profile",-1);if(selected<0 || selected>2) { return false; }
        var url=base();var g=group();
        if (url.length()<9 || !url.substring(0,8).equals("https://") || url.find("?")!=null || url.find("#")!=null || url.find("@")!=null) { return false; }
        var dot=g.find(".");
        if (dot==null || dot<1 || dot>3 || g.length()-dot<2 || g.length()-dot>3) { return false; }
        for(var i=0;i<g.length();i++) { if (i!=dot && "0123456789".find(g.substring(i,i+1))==null) { return false; } }
        return !g.substring(0,1).equals("0") && !g.substring(dot+1,dot+2).equals("0");
    }
    function key() { return base()+"|"+region()+"|"+dso()+"|"+group(); }
    function interval() { var n=number("refreshMinutes",15);return (n==5 || n==10 || n==15 || n==30 || n==60) ? n*60 : 900; }
    function stale() { var n=number("staleMinutes",30);return n>=5 && n<=120 ? n*60 : 1800; }
    function url() { return base()+"/v1/schedule?region="+region()+"&dso="+dso()+"&group="+group(); }
}
