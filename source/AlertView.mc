using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;
(:typecheck(disableBackgroundCheck))
class AlertView extends WatchUi.View {
    var _visible=false;
    var _expiryTimer;
    function initialize() { View.initialize(); }
    function onShow() { _visible=true;WatchUi.requestUpdate(); }
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
        if (_visible && r["success"]>0 && remaining>0) {
            if (_expiryTimer==null) { _expiryTimer=new Timer.Timer(); }
            _expiryTimer.start(method(:expire),remaining*1000,false);
        }
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        var x=dc.getWidth()/2;
        dc.drawText(x,70,Graphics.FONT_MEDIUM,"Air Alert UA",Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x,120,Graphics.FONT_SMALL,loc["name"],Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x,172,Graphics.FONT_LARGE,AlertLogic.text(AlertLogic.visible(r,now,Config.staleSeconds())),Graphics.TEXT_JUSTIFY_CENTER);
        var time="Last check: never";
        if (r["success"]>0) {
            var t=Gregorian.info(new Time.Moment(r["success"]),Time.FORMAT_SHORT);
            time="Updated "+t.hour.format("%02d")+":"+t.min.format("%02d")+"  "+((now-r["success"])/60).format("%d")+"m ago";
        }
        dc.drawText(x,232,Graphics.FONT_XTINY,time,Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x,267,Graphics.FONT_XTINY,r["error"],Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x,308,Graphics.FONT_SMALL,"START: Refresh",Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x,345,Graphics.FONT_XTINY,"Informational only",Graphics.TEXT_JUSTIFY_CENTER);
    }
}
(:typecheck(disableBackgroundCheck))
class AlertDelegate extends WatchUi.BehaviorDelegate {
    var _request;
    function initialize() { BehaviorDelegate.initialize(); }
    function onMenu() as Boolean { SettingsMenu.open();return true; }
    function onSelect() as Boolean {
        if (_request==null) { _request=Application.getApp().newRequest(method(:done)); }
        _request.start(true);WatchUi.requestUpdate();return true;
    }
    function done() as Void {
        var loc=Config.location();var r=Cache.load(loc);Cache.schedule(r,Time.now().value());WatchUi.requestUpdate();
    }
}
