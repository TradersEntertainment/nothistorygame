import csv, re, sys
rows = {}
with open("i18n/strings.csv", encoding="utf-8", newline="") as fh:
    rd = csv.reader(fh)
    hdr = next(rd)
    for r in rd:
        if r: rows[r[0]] = r
# keys used by my files
keys = set()
for f in ["chapter17.gd","chapter17o.gd","chapter18.gd","chapter18b.gd","chapter19.gd","chapter19o.gd"]:
    src = open("scripts/" + f, encoding="utf-8").read()
    keys |= set(re.findall(r'"([A-Z][A-Z0-9_]*)"', src))
    keys |= set(re.findall(r'"(%s)' % "", src))
mine = sorted(k for k in keys if k in rows)
bad = []
for k in mine:
    r = rows[k]
    for col, val in (("tr", r[1]), ("en", r[2])):
        if val.startswith('"') or val.endswith('"'):
            bad.append((k, col, val))
for k, col, v in bad:
    print(k, col, repr(v[:90]))
print("TOTAL used keys:", len(mine), "bad:", len(bad))
