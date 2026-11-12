# CityGeo dayanakları → ince levha eğrisi (TPS) katsayıları. Kullanım: python3 geo_tps2.py
# Dayanaklar: gerçek (e, n) metre (docs/ISTANBUL_YERLER.csv, araştırma dalı) ve dünya (x, z) (World1453.LANDMARKS).
import numpy as np

A = [  # ad, gerçek e, n, dünya x, z   (kaynak: YERLER.csv satırı ya da "eski" = önceki kestirim)
    ("ayasofya", 0, 0, -560, -1480),
    ("hippodrome", -378, -289, -470, -1440),
    ("column", -756, -11, -470, -1300),
    ("forum_tauri", -1554, 211, -390, -1130),
    ("apostles", -2394, 1156, -330, -760),
    ("pantokrator", -2016, 1212, -540, -930),
    ("pammakaristos", -2730, 2213, -575, -470),
    ("petrion_gate", -2520, 2046, -700, -650),
    ("khora", -3444, 2491, -500, -85),
    ("blachernae_palace", -3402, 3436, -668, -72),
    ("harisios", -3545, 2413, -460, 0),
    ("romanos", -4621, 823, 0, 0),
    ("pege", -5251, -1401, 340, 0),
    ("golden_gate", -4797, -1679, 650, -10),
    ("studios", -4495, -1790, 540, -158),
    ("eugenius", -336, 878, -690, -1525),
    ("galata_tower", -487, 1890, -971, -1330),
    ("damalis", 2007.64, 1391.50, -560, -2072),   # eski (CSV'de yok)
    ("eyup", -3880.87, 4363.74, -690, 250),       # eski (CSV'de yok)
]
names = [a[0] for a in A]
P = np.array([[a[1], a[2]] for a in A], float) / 1000.0
W = np.array([[a[3], a[4]] for a in A], float)
n = len(P)


def U(d):
    with np.errstate(divide="ignore", invalid="ignore"):
        return np.where(d > 0, d * d * np.log(d), 0.0)


K = U(np.linalg.norm(P[:, None] - P[None], axis=2))
L = np.zeros((n + 3, n + 3)); L[:n, :n] = K; L[:n, n] = 1; L[:n, n + 1:] = P; L[n, :n] = 1; L[n + 1:, :n] = P.T
Y = np.zeros((n + 3, 2)); Y[:n] = W
S = np.linalg.solve(L, Y); w = S[:n]; a = S[n:]


def f(r):
    r = np.array(r) / 1000.0
    return a[0] + a[1] * r[0] + a[2] * r[1] + U(np.linalg.norm(P - r, axis=1)) @ w


# Katlanma: şehrin içinde (afin sınır kutusu) Jacobian işareti
neg = 0; tot = 0; sgn = []
for e in range(-5600, 800, 100):
    for nn in range(-2000, 3600, 100):
        r = np.array([e, nn], float); f0 = f(r); jx = f(r + [1, 0]) - f0; jy = f(r + [0, 1]) - f0
        sgn.append(np.sign(jx[0] * jy[1] - jy[0] * jx[1])); tot += 1
sg = np.array(sgn)
print("TPS fold", int(min((sg > 0).sum(), (sg < 0).sum())), tot,
      "anchor err", max(np.linalg.norm(f(np.array(P[i] * 1000)) - W[i]) for i in range(n)))
print("const TPS_A0 := Vector2(%.7f, %.7f)" % tuple(a[0]))
print("const TPS_AE := Vector2(%.7f, %.7f)" % tuple(a[1]))
print("const TPS_AN := Vector2(%.7f, %.7f)" % tuple(a[2]))
for k, wi, p, ww in zip(names, w, P * 1000, W):
    print(f'\t["{k}", Vector2({p[0]:.2f}, {p[1]:.2f}), Vector2({ww[0]:.1f}, {ww[1]:.1f}), Vector2({wi[0]:.7f}, {wi[1]:.7f})],')
