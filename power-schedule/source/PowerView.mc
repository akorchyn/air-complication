using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Math;
import Toybox.Lang;
(:typecheck(disableBackgroundCheck))
class PowerView extends WatchUi.View {
    var page=0;var pageCount=1;var _opened=false;var _request;var _timer;
    function initialize() { View.initialize(); }
    function refresh() as Boolean {
        if(_request==null) { _request=Application.getApp().newRequest(method(:done)); }
        _request.start(true);WatchUi.requestUpdate();return true;
    }
    function done() as Void { PowerCache.schedule(PowerCache.load(),Time.now().value());WatchUi.requestUpdate(); }
    function onShow() {
        if(!_opened) { _opened=true;refresh(); }
        if(_timer==null) { _timer=new Timer.Timer(); }_timer.start(method(:tick),30000,true);
    }
    function onHide() { if(_timer!=null) { _timer.stop(); } }
    function tick() as Void { PowerCache.publish(PowerCache.load(),Time.now().value());WatchUi.requestUpdate(); }
    function pages(r) as Array {
        var pages=[];var data=r["data"];
        if(data instanceof Dictionary && PowerLogic.valid(data,Time.now().value())) {
            var days=data["days"];
            for(var i=0;i<days.size();i++) {
                var day=days[i];var slots=day[4];
                var status=["No planned outages","Confirmed schedule","Awaiting confirmation","Emergency shutdowns","Schedule unknown"][day[3]];
                var lines=[];
                if(slots.size()==0) { lines.add(status); }
                for(var j=0;j<slots.size();j++) {
                    var slot=slots[j];lines.add(PowerLogic.clock(slot[3])+"-"+PowerLogic.clock(slot[4])+"  "+(slot[2]==1 ? "OFF" : "ON"));
                }
                for(var start=0;start<lines.size();start+=4) {
                    var rows=[day[0]+" Kyiv",status];
                    for(var j=start;j<lines.size() && j<start+4;j++) { rows.add(lines[j]); }
                    // The current result above may be stale; these remain explicitly historical.
                    rows.add("Cached schedule; check status");pages.add(rows);
                }
            }
        }
        return pages;
    }
    function onUpdate(dc) {
        var r=PowerCache.load();var now=Time.now().value();var s=PowerLogic.summary(r,now);var extra=pages(r);pageCount=extra.size()+1;
        if(page>=pageCount) { page=0; }
        var rows=[];
        if(page==0) {
            rows=[WatchUi.loadResource(Rez.Strings.ScreenTitle),PowerConfig.name()+" / "+PowerConfig.group(),"Scheduled: "+s["value"]];
            if(s["state"].equals("SETUP")) {
                rows.add("Open Connect IQ settings");rows.add("Set adapter HTTPS URL");rows.add("Choose provider / group");
                rows.add("Keep phone connected");
            } else {
                rows.add(r["fetched"]>0 ? "Checked "+((now-r["fetched"])/60).format("%d")+"m ago" : "Never checked");
                if(r["error"].length()>0) { rows.add(r["error"]); }
                else if(r["data"] instanceof Dictionary) { rows.add("Source: "+r["data"]["updatedLabel"]+" Kyiv"); }
                rows.add(WatchUi.loadResource(Rez.Strings.RefreshHint));rows.add("Connect IQ: settings");
            }
        } else { rows=extra[page-1]; }
        rows.add(WatchUi.loadResource(Rez.Strings.PagesHint));
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        var w=dc.getWidth();var h=dc.getHeight();var font=Graphics.FONT_XTINY;var lh=dc.getFontHeight(font);
        var total=rows.size()*lh;var gap=(h*0.82-total)/(rows.size()-1);if(gap<0) { gap=0; }
        var y=(h-total-gap*(rows.size()-1))/2;
        for(var i=0;i<rows.size();i++) {
            var edge=(y-h/2).abs();var bottom=(y+lh-h/2).abs();if(bottom>edge) { edge=bottom; }
            var square=w*w/4-edge*edge;var max=2*Math.sqrt(square>0 ? square : 0)-20;
            var text=rows[i];
            if(dc.getTextWidthInPixels(text,font)>max) {
                while(text.length()>0 && dc.getTextWidthInPixels(text+"...",font)>max) { text=text.substring(0,text.length()-1); }
                text+="...";
            }
            dc.drawText(w/2,y.toNumber(),font,text,Graphics.TEXT_JUSTIFY_CENTER);y+=lh+gap;
        }
    }
}
(:typecheck(disableBackgroundCheck))
class PowerDelegate extends WatchUi.BehaviorDelegate {
    var _view;
    function initialize(view) { BehaviorDelegate.initialize();_view=view; }
    function onSelect() as Boolean { return _view.refresh(); }
    function onTap(event) as Boolean { return onSelect(); }
    function onNextPage() as Boolean { _view.page=(_view.page+1)%_view.pageCount;WatchUi.requestUpdate();return true; }
    function onPreviousPage() as Boolean { _view.page=(_view.page+_view.pageCount-1)%_view.pageCount;WatchUi.requestUpdate();return true; }
    function onSwipe(event) as Boolean {
        if(event.getDirection()==WatchUi.SWIPE_UP) { return onNextPage(); }
        if(event.getDirection()==WatchUi.SWIPE_DOWN) { return onPreviousPage(); }return false;
    }
}
(:glance)
class PowerGlance extends WatchUi.GlanceView {
    function initialize() { GlanceView.initialize(); }
    function onUpdate(dc) {
        // Cached data only: browsing the swipe/glance list never polls YASNO.
        var s=PowerLogic.summary(PowerCache.load(),Time.now().value());
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        var h=dc.getHeight();var x=dc.getWidth()/2;
        dc.drawText(x,(h/8).toNumber(),Graphics.FONT_GLANCE,"Group "+PowerConfig.group(),Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x,(h/2).toNumber(),Graphics.FONT_GLANCE,s["value"],Graphics.TEXT_JUSTIFY_CENTER);
    }
}
