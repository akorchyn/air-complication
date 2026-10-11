using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;
using Toybox.Math;
(:typecheck(disableBackgroundCheck))
class AlertView extends WatchUi.View {
    var _visible=false;
    var _expiryTimer;
    var _onOpen as Lang.Method or Null;
    function initialize(onOpen as Lang.Method or Null) { View.initialize();_onOpen=onOpen; }
    function onShow() {
        _visible=true;
        // Consume before invoking: returning from another view
        // must not trigger a second automatic request in this launch.
        var onOpen=_onOpen;_onOpen=null;
        if (onOpen!=null) { onOpen.invoke(); }
        WatchUi.requestUpdate();
    }
    function onHide() { _visible=false;if (_expiryTimer!=null) { _expiryTimer.stop(); } }
    function expire() as Void {
        var loc=Config.location();Cache.publish(Cache.load(loc),loc,Time.now().value());
        WatchUi.requestUpdate();
    }
    function onUpdate(dc) {
        var loc=Config.location();var r=Cache.load(loc);var now=Time.now().value();
        // One foreground-only deadline repaint, never a networking timer.
        // Stop it when the view leaves the screen; background uses temporal events.
        if (_expiryTimer!=null) { _expiryTimer.stop(); }
        var remaining=r["success"]+Config.staleSeconds()-now;
        if (r["lease"]>0 && r["lease"]-now<remaining) { remaining=r["lease"]-now; }
        if (_visible && r["success"]>0 && remaining>0) {
            if (_expiryTimer==null) { _expiryTimer=new Timer.Timer(); }
            _expiryTimer.start(method(:expire),remaining*1000,false);
        }
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        var time="Last check: never";
        if (r["success"]>0) {
            var t=Gregorian.info(new Time.Moment(r["success"]),Time.FORMAT_SHORT);
            time="Updated "+t.hour.format("%02d")+":"+t.min.format("%02d")+"  "+((now-r["success"])/60).format("%d")+"m ago";
        }
        var rows=[
            [WatchUi.loadResource(Rez.Strings.AppName),Graphics.FONT_TINY],
            [Config.providerName(),Graphics.FONT_XTINY],
            [loc["name"],Graphics.FONT_TINY],
            [AlertDisplay.text(AlertLogic.visible(r,now,Config.staleSeconds())),Graphics.FONT_LARGE],
            [time,Graphics.FONT_XTINY]
        ];
        if (r["error"].length()>0) { rows.add([r["error"],Graphics.FONT_XTINY]); }
        rows.add([WatchUi.loadResource(Rez.Strings.RefreshHint),Graphics.FONT_XTINY]);
        rows.add([WatchUi.loadResource(Rez.Strings.SettingsHint),Graphics.FONT_XTINY]);
        rows.add(["Info only",Graphics.FONT_XTINY]);

        // Native font sizes differ between Epix and the two Venu sizes. Lay out
        // actual line heights inside the round screen, rather than fixed pixels.
        var width=dc.getWidth();var height=dc.getHeight();var total=0;
        for(var i=0;i<rows.size();i++) { total+=dc.getFontHeight(rows[i][1]); }
        var available=height*0.84;
        if (total>available) {
            total=0;
            for(var i=0;i<rows.size();i++) {
                rows[i][1]=i==3 ? Graphics.FONT_MEDIUM : Graphics.FONT_XTINY;
                total+=dc.getFontHeight(rows[i][1]);
            }
        }
        var gap=(available-total)/(rows.size()-1);if (gap<0) { gap=0; }
        var y=(height-total-gap*(rows.size()-1))/2;
        for(var i=0;i<rows.size();i++) {
            var font=rows[i][1];var lineHeight=dc.getFontHeight(font);
            // Keep the whole line within the circle, including its top/bottom.
            var top=(y-height/2).abs();var bottom=(y+lineHeight-height/2).abs();
            var edge=top>bottom ? top : bottom;var chord=width*width/4-edge*edge;
            var maxWidth=2*Math.sqrt(chord>0 ? chord : 0)-16;
            var text=rows[i][0];
            if (dc.getTextWidthInPixels(text,font)>maxWidth) {
                while (text.length()>0 && dc.getTextWidthInPixels(text+"...",font)>maxWidth) {
                    text=text.substring(0,text.length()-1);
                }
                text=text+"...";
            }
            dc.drawText(width/2,y.toNumber(),font,text,Graphics.TEXT_JUSTIFY_CENTER);
            y+=lineHeight+gap;
        }
    }
}
(:typecheck(disableBackgroundCheck))
class AlertDelegate extends WatchUi.BehaviorDelegate {
    var _request;
    function initialize() { BehaviorDelegate.initialize(); }
    function onTap(clickEvent) as Boolean { return onSelect(); }
    function onSelect() as Boolean {
        if (_request==null) { _request=Application.getApp().newRequest(method(:done)); }
        _request.start(true);WatchUi.requestUpdate();return true;
    }
    function done() as Void {
        var loc=Config.location();var r=Cache.load(loc);Cache.schedule(r,Time.now().value());WatchUi.requestUpdate();
    }
}
