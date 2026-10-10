using Toybox.Application;
using Toybox.Complications;
using Toybox.WatchUi;
using Toybox.Graphics;
class AirAlertApp extends Application.AppBase {
 function initialize() { AppBase.initialize(); }
 function onStart(state) { Complications.updateComplication(0, {:value=>"TEST", :shortLabel=>"ALERT"}); }
 function getInitialView() { return [new SpikeView()]; }
}
class SpikeView extends WatchUi.View {
 function initialize() { View.initialize(); }
 function onUpdate(dc) { dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); dc.clear(); dc.drawText(208,190,WatchUi.loadResource(Rez.Fonts.TestFont),"TEST",Graphics.TEXT_JUSTIFY_CENTER); }
}
