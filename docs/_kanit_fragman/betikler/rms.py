import sys,subprocess,numpy as np
# rms.py avi start dur  -> 0.1 sn'lik dB
f,s,d=sys.argv[1],float(sys.argv[2]),float(sys.argv[3])
raw=subprocess.run(["ffmpeg","-v","error","-ss",str(s),"-t",str(d),"-i",f,"-vn","-ac","1","-ar","8000","-f","s16le","-"],capture_output=True).stdout
a=np.frombuffer(raw,dtype=np.int16).astype(float)/32768
n=800
out=[]
for i in range(0,len(a)//n):
    r=np.sqrt(np.mean(a[i*n:(i+1)*n]**2))+1e-9
    out.append("%.1f:%d"%(i*0.1,20*np.log10(r)))
print(" ".join(out))
