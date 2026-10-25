import csv, re, sys
sys.path.insert(0, "/home/user/nothistorygame/tools")
import importlib.util
spec = importlib.util.spec_from_file_location("vg", "/home/user/nothistorygame/tools/voice_gen.py")
vg = importlib.util.module_from_spec(spec); spec.loader.exec_module(vg)
OLD = vg.LABEL
NEW = re.compile(r'(?:^|(?<=[\s."!?…]))(?<!Mr )(?<!Mrs )(?<!, )(' + "|".join(vg.NAME_SPK) + r')(?: \([^)]*\))?:\s')
def split(rx, raw, default):
    parts, spk, pos = [], default, 0
    for m in rx.finditer(raw):
        parts.append((spk, raw[pos:m.start()])); spk = vg.NAME_SPK[m.group(1)]; pos = m.end()
    parts.append((spk, raw[pos:]))
    return [(sp, vg.clean(t).strip(' "“”')) for sp, t in parts if vg.clean(t).strip(' "“”')]
for lang, col in [("tr","tr"),("en","en")]:
    for r in csv.DictReader(open("/home/user/nothistorygame/docs/voice/VOICE_MAP.csv", encoding="utf-8")):
        raw = r[col]
        a = split(OLD, raw, r["konusmaci"]); b = split(NEW, raw, r["konusmaci"])
        if a != b:
            print(lang, r["anahtar"], "\n  OLD", [(s,t[:60]) for s,t in a], "\n  NEW", [(s,t[:60]) for s,t in b])
