# usage: step.py <label-regex> <+N|-N> [nth]
import re,subprocess,sys,os,time
A=os.path.expanduser('~/Library/Android/sdk/platform-tools/adb')
S=os.path.dirname(os.path.abspath(__file__))
def dump():
    subprocess.run([A,'shell','uiautomator','dump','/sdcard/ui.xml'],capture_output=True)
    return subprocess.run([A,'exec-out','cat','/sdcard/ui.xml'],capture_output=True,text=True).stdout
def parse(x):
    out=[]
    for n in re.findall(r'<node [^>]*>',x):
        t=re.search(r' text="([^"]*)"',n).group(1) or re.search(r'content-desc="([^"]*)"',n).group(1)
        out.append((t,[int(v) for v in re.findall(r'\d+',re.search(r'bounds="([^"]+)"',n).group(1))]))
    return out
pat,delta=re.compile(sys.argv[1],re.I),int(sys.argv[2]); nth=int(sys.argv[3]) if len(sys.argv)>3 else 0
x=dump()
nodes=parse(x)
labels=[b for t,b in nodes if pat.search(t)]
if len(labels)<=nth: print('NOT FOUND',sys.argv[1]); sys.exit(1)
lb=labels[nth]; cy=(lb[1]+lb[3])//2
want='Increase count' if delta>0 else 'Decrease count'
btn=[b for t,b in nodes if t==want and b[1]-40<=cy<=b[3]+40 and b[0]>lb[2]]
if not btn: print('NO BUTTON on row'); sys.exit(1)
b=btn[0]
for _ in range(abs(delta)):
    subprocess.run([A,'shell','input','tap',str((b[0]+b[2])//2),str((b[1]+b[3])//2)]); time.sleep(0.6)
x=dump()
nodes=parse(x)
vals=[t for t,bb in nodes if bb[0]>=790 and bb[2]<=880 and bb[1]-40<=cy<=bb[3]+40]
print(sys.argv[1],'->',vals)
