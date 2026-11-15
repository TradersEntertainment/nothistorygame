import re,sys,glob,statistics as st
for pat in sys.argv[1:]:
    w1=[];w2=[]
    for f in glob.glob(pat):
        for l in open(f,errors='ignore'):
            m=re.match(r'WAVERUNNER wave=(\d)/2 won=\w+ t=([\d.]+)',l)
            if m: (w1 if m.group(1)=='1' else w2).append(float(m.group(2)))
    f=lambda a: '%.1f [%.1f–%.1f] (n %d)'%(st.median(a),min(a),max(a),len(a)) if a else '-'
    print(pat, '1.dalga', f(w1), '2.dalga', f(w2))
