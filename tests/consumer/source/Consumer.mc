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
   if (c.longLabel.equals("Air Alert UA")) { Complications.subscribeToUpdates(id); changed(id); }
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
 function onUpdate(dc) { dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK); dc.clear(); dc.drawText(208,190,WatchUi.loadResource(Rez.Fonts.TestFont),Application.getApp().textValue,Graphics.TEXT_JUSTIFY_CENTER); }
}
