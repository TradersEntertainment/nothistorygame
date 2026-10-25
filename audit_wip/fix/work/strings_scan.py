import csv, collections, re, sys
rows = list(csv.reader(open("/home/user/nothistorygame/i18n/strings.csv", encoding="utf-8", newline="")))
hdr, body = rows[0], rows[1:]
cnt = collections.Counter(r[0] for r in body if r)
dups = [k for k, c in cnt.items() if c > 1]
print("DUPS", dups)
q = [(r[0], r[2]) for r in body if len(r) >= 3 and r[2].startswith('"') and r[2].endswith('"')]
print("EN_OUTER_QUOTES", len(q))
print("sample", q[:3])
# narration before first quote or label, not parenthesized
cand = []
for r in body:
    if len(r) < 3: continue
    for col in (1, 2):
        t = r[col]
        if not r[0].startswith(("REACT_", "D", "SIEGE")): continue
        head = re.split(r'"|\w+: ', t, maxsplit=1)[0].strip()
        if head and not head.startswith(("(", "[")) and len(head) > 6 and re.search(r"[a-zA-ZçğıöşüÇĞİÖŞÜ]{3}", head):
            cand.append((r[0], hdr[col], head[:90]))
print("NARRATION_HEAD", len(cand))
for c in cand: print(c)
