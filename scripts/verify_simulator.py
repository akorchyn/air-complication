#!/usr/bin/env python3
"""Optional Linux X11 automation for the separate publisher + consumer fixtures.
Requires python-xlib and a RUNNING Garmin simulator. Never uses the live API.
Usage: CIQ_SDK=/path/to/sdk CIQ_KEY=/path/to/key.der DISPLAY=:0 python scripts/verify_simulator.py [1|10|25|50]
The test temporarily changes only tests/integration/source/ProbeConfig.mc.
"""
import os,sys,time,subprocess
from pathlib import Path
from Xlib import display,X,XK
from Xlib.ext import xtest
ROOT=Path(__file__).resolve().parents[1]
SDK=Path(os.environ['CIQ_SDK']);KEY=os.environ['CIQ_KEY'];rows=int(sys.argv[1]) if len(sys.argv)>1 else 1
probe=ROOT/'tests/integration/source/ProbeConfig.mc';original=probe.read_text()
d=display.Display()
def click(x,y):
    xtest.fake_input(d,X.MotionNotify,x=x,y=y);xtest.fake_input(d,X.ButtonPress,1);d.sync();time.sleep(.1)
    xtest.fake_input(d,X.ButtonRelease,1);d.sync();time.sleep(.3)
def key(name):
    k=d.keysym_to_keycode(XK.string_to_keysym(name));xtest.fake_input(d,X.KeyPress,k);xtest.fake_input(d,X.KeyRelease,k);d.sync();time.sleep(.2)
def window(title):
    for w in d.screen().root.query_tree().children:
        if title in (w.get_wm_name() or ''):return w
    raise RuntimeError('Window not found: '+title)
def run(prg,log):
    handle=log.open('w')
    p=subprocess.Popen(['java','-classpath',str(SDK/'bin/monkeybrains.jar'),'com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux','-f',str(prg),'-d','epix2','-s',str(SDK/'bin/shell')],cwd=ROOT,stdout=handle,stderr=subprocess.STDOUT)
    deadline=time.monotonic()+30
    while time.monotonic()<deadline and log.stat().st_size==0 and p.poll() is None:time.sleep(.2)
    if log.stat().st_size==0:raise RuntimeError("Simulator did not start "+str(prg))
    time.sleep(.3);return p,handle
processes=[]
try:
    probe.write_text(f'(:background)\nmodule ProbeConfig {{ const ROWS={rows}; }}\n')
    result=subprocess.run([str(ROOT/'scripts/build.sh'),'integration'],cwd=ROOT,capture_output=True,text=True)
    (ROOT/f'docs/probe-{rows}-build.log').write_text(result.stdout+result.stderr)
    if result.returncode:raise RuntimeError('Fixture compilation failed')
    processes.append(run(ROOT/'artifacts/integration.prg',ROOT/f'docs/probe-{rows}-publisher.log'))
    key('Escape');click(614,360) # Epix START: production manual Refresh delegate
    time.sleep(.5)
    processes.append(run(ROOT/'artifacts/consumer.prg',ROOT/f'docs/probe-{rows}-consumer.log'))
    key('Escape');click(145,12);click(180,179) # Simulation > Background Events
    w=window('Background Events');g=w.get_geometry();pos=w.translate_coords(d.screen().root,0,0)
    # Popup is centered at 204,383 on the standard Epix simulation window.
    x,y=g.x,g.y
    click(x+200,y+125);key('Home');key('Down');key('Return') # Air Alert UA
    click(x+166,y+170);time.sleep(1)
    out=(ROOT/f'docs/probe-{rows}-consumer.log').read_text()
    print(out)
    if rows<=10 and 'CONSUMER RECEIVED: RED' not in out:raise RuntimeError('No consumer RED update')
    if rows==1:
        subprocess.run(['import','-window',str(window('CIQ Simulator').id),str(ROOT/'docs/background-red.png')],check=True)
finally:
    probe.write_text(original)
    for p,h in processes:p.terminate();h.close()
