import csv, re
SCR = "/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/"
rows = {}
order = []
with open("i18n/strings.csv", encoding="utf-8", newline="") as fh:
    rd = csv.reader(fh); next(rd)
    for r in rd:
        if r and r[0] not in rows:
            rows[r[0]] = r; order.append(r[0])
src = ""
for f in ["chapter18b.gd", "chapter19.gd", "chapter19o.gd", "chapter17.gd", "chapter17o.gd", "chapter18.gd"]:
    src += open("scripts/" + f, encoding="utf-8").read()
used = set(re.findall(r'"([A-Z][A-Z0-9_]*)"', src))
def norm(v):
    if v.startswith('"') and v.endswith('"') and len(v) >= 2:
        v = v.strip('"')            # sarma tırnakları (bazı satırlarda 3 ya da 7 kat) tamamen soy
        if '""' in v:
            v = v.replace('""', '"')
    return v
out = []
for k in order:
    if k not in used:
        continue
    r = rows[k]
    tr, en = r[1], r[2]
    if not (tr.startswith('"') or tr.endswith('"') or en.startswith('"') or en.endswith('"')):
        continue
    ntr, nen = norm(tr), norm(en)
    out.append((k, ntr, nen))
def q(s):
    return '"' + s.replace('"', '""') + '"'
with open(SCR + "F06_bolum17-19_strings.csv", "w", encoding="utf-8", newline="") as fh:
    for k, a, b in out:
        fh.write("%s,%s,%s\n" % (k, q(a), q(b)))
print(len(out), "rows")
for k, a, b in out:
    if k in ("D19O_T_NOTICE", "UI_C19O_TELL", "D18B_G_02"):
        print(k, "|", a[:120], "|", b[:160])
