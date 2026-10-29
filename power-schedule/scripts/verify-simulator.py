#!/usr/bin/env python3
"""Mocked publisher/consumer delivery and maximum-size background probe.
Requires a running Garmin simulator and python-xlib. Never calls YASNO.
"""
import os,sys,time,subprocess,json
from pathlib import Path
from Xlib import display,X,XK
from Xlib.ext import xtest
ROOT=Path(__file__).resolve().parents[1]
SDK=Path(os.environ['CIQ_SDK']);device='epix2pro51mm';prefix='integration'
profile=json.loads((Path.home()/'.Garmin/ConnectIQ/Devices'/device/'simulator.json').read_text())
d=display.Display()
def click(x,y):
    xtest.fake_input(d,X.MotionNotify,x=x,y=y);xtest.fake_input(d,X.ButtonPress,1);d.sync();time.sleep(.1)
    xtest.fake_input(d,X.ButtonRelease,1);d.sync();time.sleep(.3)
def key(name):
    k=d.keysym_to_keycode(XK.string_to_keysym(name));xtest.fake_input(d,X.KeyPress,k);xtest.fake_input(d,X.KeyRelease,k);d.sync();time.sleep(.2)
def window(title):
    deadline=time.monotonic()+5
    while time.monotonic()<deadline:
        for w in d.screen().root.query_tree().children:
            if title in (w.get_wm_name() or '') and w.get_attributes().map_state==X.IsViewable:return w
        time.sleep(.1)
    raise RuntimeError('Window not found: '+title)
def temporal():
    key('Escape');click(145,12) # Simulation menu.
    # GTK scales these 11 menu rows with the desktop font. Select row six
    # relative to the popup geometry rather than hard-coding its screen Y.
    popup=next(w for w in d.screen().root.query_tree().children
        if w.get_attributes().override_redirect and w.get_wm_name()=='simulator'
        and w.get_geometry().height>200)
    g=popup.get_geometry();click(g.x+g.width//2,g.y+int(g.height*5.5/11))
    w=window('Background Events');g=w.get_geometry();x,y=g.x,g.y
    click(x+200,y+125);key('Home');key('Return') # Power Schedule Fixture, first in this test session
    subprocess.run(['import','-window','root','/workspace/tools/power-background-dialog.png'],check=True)
    click(x+166,y+170);time.sleep(1)
def run(prg,log):
    handle=log.open('w')
    p=subprocess.Popen(['java','-classpath',str(SDK/'bin/monkeybrains.jar'),'com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux','-f',str(prg),'-d',device,'-s',str(SDK/'bin/shell')],cwd=ROOT,stdout=handle,stderr=subprocess.STDOUT)
    deadline=time.monotonic()+30
    while time.monotonic()<deadline and log.stat().st_size==0 and p.poll() is None:time.sleep(.2)
    if log.stat().st_size==0:raise RuntimeError("Simulator did not start "+str(prg))
    time.sleep(.3);return p,handle
def wait_for_value(value):
    # Publisher completion and consumer notification are asynchronous. Wait for
    # the received value instead of assuming a one-second service/repaint delay.
    log=ROOT/f'docs/{prefix}-consumer.log';deadline=time.monotonic()+10
    while time.monotonic()<deadline:
        if f'POWER CONSUMER: {value}' in log.read_text():return
        time.sleep(.1)
    raise RuntimeError('Consumer did not receive '+value+' within 10 seconds')
processes=[]
try:
    key('Escape')
    processes.append(run(ROOT/'artifacts/power-integration-epix2pro51mm.prg',ROOT/'docs/integration-publisher.log'))
    processes.append(run(ROOT/'artifacts/power-consumer-epix2pro51mm.prg',ROOT/'docs/integration-consumer.log'))
    wait_for_value('OFF 10:00')
    temporal()
    wait_for_value('ON')
    subprocess.run(['import','-window',hex(window('CIQ Simulator').id),str(ROOT/'docs/integration-consumer.png')],check=True,timeout=10)
    print((ROOT/'docs/integration-consumer.log').read_text())
finally:
    for p,h in processes:p.terminate();h.close()
