import csv, re, importlib.util
spec = importlib.util.spec_from_file_location("vg", "/home/user/nothistorygame/tools/voice_gen.py")
vg = importlib.util.module_from_spec(spec); spec.loader.exec_module(vg)
for col in ["tr","en"]:
    for r in csv.DictReader(open("/home/user/nothistorygame/docs/voice/VOICE_MAP.csv", encoding="utf-8")):
        raw = r[col]
        for m in vg.LABEL.finditer(raw):
            after = raw[m.end():m.end()+12]
            before = raw[max(0,m.start()-14):m.start()+len(m.group(0))]
            print(col, r["anahtar"], "|", before, "|", after.replace("\n"," "), "" if after[:1] in "\"'“‘" else "  <<NOQ")
