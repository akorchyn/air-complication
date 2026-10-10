using Toybox.System;
using Toybox.Background;
using Toybox.Time;
(:background)
class AlertService extends System.ServiceDelegate {
    var _request;
    function initialize() { ServiceDelegate.initialize(); }
    function onTemporalEvent() as Void {
        var location=Config.location();
        var r=Cache.load(location);
        var now=Time.now().value();
        Cache.publish(r,location,now);
        // Arrange a recovery event before the OS's 30-second service deadline.
        Cache.schedule(r,now);
        _request=Toybox.Application.getApp().newRequest(method(:finish));
        _request.start(false);
    }
    function finish() as Void {
        var location=Config.location();var r=Cache.load(location);
        Cache.schedule(r,Time.now().value());
        Background.exit(null);
    }
}
