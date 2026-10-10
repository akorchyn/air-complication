#!/usr/bin/env python3
"""Optional Linux X11 automation for the separate publisher + consumer fixtures.
Requires python-xlib and a RUNNING Garmin simulator. Never uses the live API.
Usage: CIQ_SDK=/path/to/sdk CIQ_KEY=/path/to/key.der DISPLAY=:0 python scripts/verify_simulator.py [1|10|25|50] [text|dots] [epix2|venu441mm|venu445mm]
The test temporarily changes only tests/integration/source/ProbeConfig.mc.
"""
import os,sys,time,subprocess,json
from pathlib import Path
from Xlib import display,X,XK
from Xlib.ext import xtest
ROOT=Path(__file__).resolve().parents[1]
SDK=Path(os.environ['CIQ_SDK']);KEY=os.environ['CIQ_KEY'];rows=int(sys.argv[1]) if len(sys.argv)>1 else 1
mode=sys.argv[2] if len(sys.argv)>2 else 'text'
if mode not in ['text','dots']:raise SystemExit('Mode must be text or dots')
device=sys.argv[3] if len(sys.argv)>3 else 'epix2'
if device not in ['epix2','venu441mm','venu445mm']:raise SystemExit('Unsupported device')
suffix='' if device=='epix2' else '-'+device
profile=json.loads((Path.home()/'.Garmin/ConnectIQ/Devices'/device/'simulator.json').read_text())
prefix=f'probe-{rows}' if mode=='text' else f'dots-{rows}'
prefix+=suffix
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
def temporal():
    key('Escape');click(145,12);click(180,179) # Simulation > Background Events
    w=window('Background Events');g=w.get_geometry();x,y=g.x,g.y
    click(x+200,y+125);key('Home');key('Down');key('Return') # Air Alert UA
    click(x+166,y+170);time.sleep(1)
def run(prg,log):
    handle=log.open('w')
    p=subprocess.Popen(['java','-classpath',str(SDK/'bin/monkeybrains.jar'),'com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux','-f',str(prg),'-d',device,'-s',str(SDK/'bin/shell')],cwd=ROOT,stdout=handle,stderr=subprocess.STDOUT)
    deadline=time.monotonic()+30
    while time.monotonic()<deadline and log.stat().st_size==0 and p.poll() is None:time.sleep(.2)
    if log.stat().st_size==0:raise RuntimeError("Simulator did not start "+str(prg))
    time.sleep(.3);return p,handle
processes=[]
try:
    probe.write_text(f'(:background)\nmodule ProbeConfig {{ const ROWS={rows}; const DISPLAY_MODE={1 if mode=="dots" else 0}; }}\n')
    result=subprocess.run([str(ROOT/'scripts/build.sh'),'integration',device],cwd=ROOT,capture_output=True,text=True)
    (ROOT/f'docs/{prefix}-build.log').write_text(result.stdout+result.stderr)
    if result.returncode:raise RuntimeError('Fixture compilation failed')
    key('Escape')
    processes.append(run(ROOT/f'artifacts/integration{suffix}.prg',ROOT/f'docs/{prefix}-publisher.log'))
    key('Escape')
    # Device image begins below the simulator's 27-pixel menu bar.
    target=profile['display']['location'] if device!='epix2' else next(k['location'] for k in profile['keys'] if k['id']=='enter')
    click(target['x']+target['width']//2,target['y']+target['height']//2+27)
    time.sleep(.5)
    processes.append(run(ROOT/f'artifacts/consumer{suffix}.prg',ROOT/f'docs/{prefix}-consumer.log'))
    if rows==1 and device!='epix2':
        subprocess.run(['import','-window',hex(window('CIQ Simulator').id),str(ROOT/f'docs/{prefix}-manual.png')],check=True,timeout=10)
    temporal()
    if mode=='dots' and rows<=10:temporal() # Valid empty response must publish green.
    out=(ROOT/f'docs/{prefix}-consumer.log').read_text()
    print(out)
    expected='RED' if mode=='text' else '🔴'
    yellow='YELLOW' if mode=='text' else '🟡'
    if rows<=10 and (f'CONSUMER RECEIVED: {expected}' not in out or f'CONSUMER RECEIVED: {yellow}' not in out):raise RuntimeError('Missing consumer manual/background update')
    if mode=='dots' and rows<=10 and 'CONSUMER RECEIVED: 🟢' not in out:raise RuntimeError('Missing consumer green update')
    if rows==1 and mode=='text':
        screenshot='background-red.png' if device=='epix2' else f'{prefix}-background.png'
        subprocess.run(['import','-window',hex(window('CIQ Simulator').id),str(ROOT/f'docs/{screenshot}')],check=True,timeout=10)
finally:
    probe.write_text(original)
    for p,h in processes:p.terminate();h.close()
