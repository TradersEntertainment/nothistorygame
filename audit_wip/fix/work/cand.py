import csv, sys, re, collections, importlib.util, json
spec = importlib.util.spec_from_file_location("vg", "/home/user/nothistorygame/tools/voice_gen.py")
vg = importlib.util.module_from_spec(spec); spec.loader.exec_module(vg)
lang = sys.argv[1]; targets = sys.argv[2:]
cast = vg.load_cast(lang)
def root(spk):
    c = cast.get(spk) or {}; name = spk; seen = set()
    while "same_as" in c and name not in seen:
        seen.add(name); name = c["same_as"]; c = cast.get(name) or {}
    return name if c.get("voice_id") else None
scenes = collections.defaultdict(set)   # speaker -> set of scene groups
for r in csv.DictReader(open("/home/user/nothistorygame/docs/voice/VOICE_MAP.csv", encoding="utf-8")):
    if r["konusmaci"] == "?": continue
    m = re.match(r"^D(\d+[A-Z]?)_", r["anahtar"])
    if not m: continue
    scenes[r["konusmaci"]].add(m.group(1))
def scenes_of_root(rt):
    # rt and all speakers resolving to rt
    s = set(scenes.get(rt, set()))
    for k in cast:
        if not k.startswith("_") and root(k) == rt: s |= scenes.get(k, set())
    return s
roots = sorted({root(k) for k in cast if not k.startswith("_") and root(k)})
print("ROOTS", lang, [(r, cast[r].get("gender"), cast[r].get("voice_name","")[:30]) for r in roots])
for t in targets:
    ts = scenes.get(t, set())
    cands = []
    for rt in roots:
        if rt == root(t): continue
        ov = scenes_of_root(rt) & ts
        if not ov:
            cands.append((rt, cast[t].get("gender") == cast[rt].get("gender")))
    print(t, "scenes:", sorted(ts), "gender:", cast.get(t,{}).get("gender"), "cur root:", root(t))
    print("   candidates (root, gender_match):", cands)
