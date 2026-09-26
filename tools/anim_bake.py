#!/usr/bin/env python3
"""Hazır iskelet animasyonlarını (Quaternius Universal Animation Library, CC0) oyunun kendi karakterlerine aktarmak için
pişirir. Kemik açıları değil, uzuvların YÖNÜ saklanır: her karede üst kol, ön kol, uyluk, baldır, gövde ve baş
doğrultusu (karakterin kendi uzayında, yüz +Z). Böylece iskeletler farklı olsa da hareket bizim eklemlere oturur.

Kullanım: python3 tools/anim_bake.py <UAL1.glb> <UAL2.glb> ... -o assets/anim/ual.json
"""
import json, struct, sys, math, argparse
import numpy as np

BONES = {
    "ua_r": ("upperarm_r", "lowerarm_r"), "la_r": ("lowerarm_r", "hand_r"),
    "ua_l": ("upperarm_l", "lowerarm_l"), "la_l": ("lowerarm_l", "hand_l"),
    "th_r": ("thigh_r", "calf_r"), "ca_r": ("calf_r", "foot_r"),
    "th_l": ("thigh_l", "calf_l"), "ca_l": ("calf_l", "foot_l"),
    "sp": ("pelvis", "neck_01"), "hd": ("neck_01", "Head"),
}
ORDER = ["ua_r", "la_r", "ua_l", "la_l", "th_r", "ca_r", "th_l", "ca_l", "sp", "hd"]
FPS = 30.0


def load_glb(path):
    d = open(path, "rb").read()
    jl = struct.unpack("<I", d[12:16])[0]
    j = json.loads(d[20:20 + jl])
    off = 20 + jl
    bl = struct.unpack("<I", d[off:off + 4])[0]
    binc = d[off + 8:off + 8 + bl]
    return j, binc


def accessor(j, binc, i):
    a = j["accessors"][i]
    bv = j["bufferViews"][a["bufferView"]]
    comp = {5126: ("f", 4), 5123: ("H", 2), 5125: ("I", 4), 5121: ("B", 1)}[a["componentType"]]
    n = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}[a["type"]]
    start = bv.get("byteOffset", 0) + a.get("byteOffset", 0)
    stride = bv.get("byteStride", 0) or comp[1] * n
    out = np.zeros((a["count"], n), dtype=np.float64)
    for k in range(a["count"]):
        o = start + k * stride
        out[k] = struct.unpack("<" + comp[0] * n, binc[o:o + comp[1] * n])
    return out


def quat_to_mat(q):
    x, y, z, w = q
    return np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                     [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                     [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])


def slerp(a, b, t):
    d = np.dot(a, b)
    if d < 0:
        b = -b; d = -d
    if d > 0.9995:
        r = a + t * (b - a)
        return r / np.linalg.norm(r)
    th = math.acos(d)
    return (math.sin((1 - t) * th) * a + math.sin(t * th) * b) / math.sin(th)


def sample(times, vals, t, path):
    if t <= times[0]:
        return vals[0]
    if t >= times[-1]:
        return vals[-1]
    i = np.searchsorted(times, t) - 1
    f = (t - times[i]) / (times[i + 1] - times[i])
    if path == "rotation":
        return slerp(vals[i], vals[i + 1], f)
    return vals[i] + f * (vals[i + 1] - vals[i])


def bake(path):
    j, binc = load_glb(path)
    nodes = j["nodes"]
    parent = {}
    for i, n in enumerate(nodes):
        for c in n.get("children", []):
            parent[c] = i
    name_to = {n.get("name"): i for i, n in enumerate(nodes)}
    rest = []
    for n in nodes:
        rest.append((np.array(n.get("translation", [0, 0, 0]), float), np.array(n.get("rotation", [0, 0, 0, 1]), float),
                     np.array(n.get("scale", [1, 1, 1]), float)))
    out = {}
    for anim in j["animations"]:
        ch = []
        tmax = 0.0
        for c in anim["channels"]:
            s = anim["samplers"][c["sampler"]]
            times = accessor(j, binc, s["input"])[:, 0]
            vals = accessor(j, binc, s["output"])
            tmax = max(tmax, times[-1])
            ch.append((c["target"]["node"], c["target"]["path"], times, vals))
        nf = max(2, int(round(tmax * FPS)) + 1)
        frames = []
        hand_pos = []
        for f in range(nf):
            t = min(f / FPS, tmax)
            trs = [list(r) for r in rest]
            for node, p, times, vals in ch:
                v = sample(times, vals, t, p)
                k = {"translation": 0, "rotation": 1, "scale": 2}.get(p)
                if k is not None:
                    trs[node][k] = np.array(v, float)
            cache = {}

            def world(i):
                if i in cache:
                    return cache[i]
                tr, q, sc = trs[i]
                m = np.eye(4)
                m[:3, :3] = quat_to_mat(q) * sc
                m[:3, 3] = tr
                if i in parent:
                    m = world(parent[i]) @ m
                cache[i] = m
                return m
            pos = {nm: world(name_to[nm])[:3, 3] for nm in
                   ["upperarm_r", "lowerarm_r", "hand_r", "upperarm_l", "lowerarm_l", "hand_l", "thigh_r", "calf_r",
                    "foot_r", "thigh_l", "calf_l", "foot_l", "pelvis", "neck_01", "Head", "ball_l", "ball_r", "root"]}
            frames.append(pos)
        out[anim["name"]] = frames
    return out


def to_character_space(frames_by_anim):
    # Yüz yönü: T-poz/ilk kareden ayak ucu (ball) - ayak bileği yönü; yukarı +Y. Karakteri +Z'ye çevir.
    # Sağ el hangi yanda kalıyor: kılıç kolu bizde +X tarafı (arm_r). Gerekirse aynala.
    ref = frames_by_anim.get("A_TPose") or next(iter(frames_by_anim.values()))
    p = ref[0]
    fwd = (p["ball_l"] - p["foot_l"]) + (p["ball_r"] - p["foot_r"])
    fwd[1] = 0
    fwd /= np.linalg.norm(fwd)
    ang = math.atan2(fwd[0], fwd[2])     # +Z'ye döndürmek için
    c, s = math.cos(-ang), math.sin(-ang)
    R = np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]])
    hand_r = R @ p["hand_r"]
    mirror = hand_r[0] < 0      # sağ el -X'te ise aynala (bizde kılıç kolu +X)
    return R, mirror


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = set(x for x in args.only.split(",") if x)
    result = {"fps": FPS, "order": ORDER, "anims": {}}
    for f in args.files:
        fr = bake(f)
        R, mirror = to_character_space(fr)
        for name, frames in fr.items():
            if only and name not in only:
                continue
            rows = []
            speeds = []
            prev = None
            for p in frames:
                q = {k: R @ v for k, v in p.items()}
                if mirror:
                    # Bizde kılıç kolu (arm_r) +X yanında: sağ el oraya gelsin diye yalnız X aynalanır, adlar değişmez
                    for k in q:
                        q[k] = q[k] * np.array([-1, 1, 1])
                row = []
                for key in ORDER:
                    a, b = BONES[key]
                    d = q[b] - q[a]
                    n = np.linalg.norm(d)
                    d = d / n if n > 1e-6 else np.array([0, -1, 0])
                    row += [round(float(x), 3) for x in d]
                # kalça yüksekliği (çömelme, yere yığılma): T-poza göre oran
                row.append(round(float(q["pelvis"][1]), 3))
                rows.append(row)
                h = q["hand_r"]
                if prev is not None:
                    speeds.append(float(np.linalg.norm(h - prev)))
                prev = h
            hit = int(np.argmax(speeds)) + 1 if speeds else 0
            result["anims"][name] = {"frames": rows, "hit": hit}
    # kalça yüksekliğini T-poza göre normalize et
    base = None
    if "A_TPose" in result["anims"]:
        base = result["anims"]["A_TPose"]["frames"][0][-1]
    for a in result["anims"].values():
        for r in a["frames"]:
            r[-1] = round(r[-1] / base, 3) if base else 1.0
    json.dump(result, open(args.out, "w"), separators=(",", ":"))
    print("pişirildi:", len(result["anims"]), "animasyon ->", args.out)


if __name__ == "__main__":
    main()
