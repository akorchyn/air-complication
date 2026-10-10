using Toybox.Application;
using Toybox.Complications;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
class ConsumerApp extends Application.AppBase {
 var textValue = "NO PUBLISHER";
 function initialize() { AppBase.initialize(); }
 function getInitialView() { return [new ConsumerView()]; }
 function onStart(state) {
  Complications.registerComplicationChangeCallback(method(:changed));
  var iter = Complications.getComplications();
  var c = iter.next();
  while (c != null) {
   var id = c.complicationId;
   // Built-in complications on newer devices may have no long label.
   if (c.longLabel instanceof Lang.String && c.longLabel.equals("Air Alert UA")) { Complications.subscribeToUpdates(id); changed(id); }
   c = iter.next();
  }
 }
 function changed(id as Complications.Id) as Void {
  var c = Complications.getComplication(id);
  textValue = c.value == null ? "N/A" : c.value.toString();
  System.println("CONSUMER RECEIVED: " + textValue);
  WatchUi.requestUpdate();
 }
}
class ConsumerView extends WatchUi.WatchFace {
 function initialize() { WatchFace.initialize(); }
 function onUpdate(dc) {
  dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
  var value=Application.getApp().textValue;
  // This fixture font is ASCII-only. The callback log retains the exact Unicode
  // value; these captions do not claim to verify a consumer's emoji rendering.
  if (value.equals("🟢")) { value="GREEN DOT"; }
  else if (value.equals("🟡")) { value="YELLOW DOT"; }
  else if (value.equals("🔴")) { value="RED DOT"; }
  else if (value.equals("Немає") || value.equals("НЕМАЄ") || value.equals("немає")) { value="CLEAR UA"; }
  else if (value.equals("Жовта") || value.equals("ЖОВТА") || value.equals("жовта")) { value="YELLOW UA"; }
  else if (value.equals("Червона") || value.equals("ЧЕРВОНА") || value.equals("червона")) { value="RED UA"; }
  dc.drawText(dc.getWidth()/2,dc.getHeight()/2-18,WatchUi.loadResource(Rez.Fonts.TestFont),value,Graphics.TEXT_JUSTIFY_CENTER);
 }
}
