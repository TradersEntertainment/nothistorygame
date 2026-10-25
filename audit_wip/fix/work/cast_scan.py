import csv, sys, re, collections, importlib.util
spec = importlib.util.spec_from_file_location("vg", "/home/user/nothistorygame/tools/voice_gen.py")
vg = importlib.util.module_from_spec(spec); spec.loader.exec_module(vg)
lang = sys.argv[1]; chapters = set(sys.argv[2:])
cast = vg.load_cast(lang)
def root(spk):
    c = cast.get(spk) or {}; name = spk; seen = set()
    while "same_as" in c and name not in seen:
        seen.add(name); name = c["same_as"]; c = cast.get(name) or {}
    return name if c.get("voice_id") else None
by_ch = collections.defaultdict(set)
for r in csv.DictReader(open("/home/user/nothistorygame/docs/voice/VOICE_MAP.csv", encoding="utf-8")):
    if r["konusmaci"] == "?": continue
    m = re.match(r"^D(\d+[A-Z]?)_", r["anahtar"])
    g = m.group(1) if m else r["bolum"]
    by_ch[g].add(r["konusmaci"])
for ch in sorted(by_ch):
    if chapters and ch not in chapters: continue
    roots = collections.defaultdict(list)
    for s in sorted(by_ch[ch]):
        roots[root(s)].append(s)
    for rt, ss in roots.items():
        if rt and len(ss) > 1:
            print(f"ch{ch}: voice={rt} <- {ss}")
