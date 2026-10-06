#!/usr/bin/env python3
"""Kodun andığı ama dosyası olmayan efekt sesleri, sentezle (kayıt yok, telif yok).

Her ses birkaç basit parçadan kurulur: süzülmüş gürültü, sönümlü sinüs, sürtünme darbeleri ve rezonans süzgeçleri.
Çıktı mono 44.1 kHz OGG Vorbis; oyun assets/audio/sfx/<ad>.ogg yolundan okur (Audio.sfx).

    pip install numpy scipy soundfile
    python3 tools/sfx_gen.py                      # hepsi → assets/audio/sfx/
    python3 tools/sfx_gen.py camera cough --out /tmp/sfx
"""
import argparse, os, sys

import numpy as np
import soundfile as sf
from scipy.signal import butter, lfilter, sosfilt

SR = 44100
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _rng(seed):
    return np.random.default_rng(seed)


def secs(n):
    return np.arange(int(n * SR)) / SR


def noise(dur, seed=1):
    return _rng(seed).standard_normal(int(dur * SR))


def decay(dur, tau):
    return np.exp(-secs(dur) / tau)


def band(x, lo, hi, order=2):
    sos = butter(order, [lo / (SR / 2), min(hi, SR / 2 - 100) / (SR / 2)], btype="band", output="sos")
    return sosfilt(sos, x)


def low(x, fc, order=2):
    return sosfilt(butter(order, fc / (SR / 2), btype="low", output="sos"), x)


def high(x, fc, order=2):
    return sosfilt(butter(order, fc / (SR / 2), btype="high", output="sos"), x)


def reson(x, f, q):
    """İki kutuplu rezonans: f'de çınlayan dar bant (tahta, metal gövde)."""
    w = 2 * np.pi * f / SR
    r = np.exp(-w / (2 * q))
    b = [1 - r]
    a = [1, -2 * r * np.cos(w), r * r]
    return lfilter(b, a, x)


def put(out, x, at):
    i = int(at * SR)
    n = min(len(x), len(out) - i)
    if n > 0:
        out[i:i + n] += x[:n]


def finish(x, peak_db=-1.0, fade=0.006):
    x = x - np.mean(x)
    f = int(fade * SR)
    if f > 0 and len(x) > 2 * f:
        x[:f] *= np.linspace(0, 1, f)
        x[-f:] *= np.linspace(1, 0, f)
    m = np.max(np.abs(x)) or 1.0
    return (x / m * 10 ** (peak_db / 20)).astype(np.float32)


def adsr(dur, a, r):
    n = int(dur * SR)
    e = np.ones(n)
    na, nr = max(1, int(a * SR)), max(1, int(r * SR))
    e[:na] = np.linspace(0, 1, na)
    e[-nr:] *= np.linspace(1, 0, nr)
    return e


# ------------------------------------------------------------------ sesler

def camera():
    """Anlık baskılı makinenin deklanşörü: perde açılır-kapanır, yay çınlar, flaş patlar, gövde tok vurur."""
    out = np.zeros(int(0.34 * SR))
    for at, lo, hi, d, amp, seed in [(0.0, 2600, 6200, 0.014, 1.0, 3), (0.031, 1900, 4800, 0.018, 0.75, 4)]:
        c = band(noise(d, seed), lo, hi) * decay(d, d / 5)
        put(out, amp * c / np.max(np.abs(c)), at)
    t = secs(0.07)
    put(out, 0.45 * np.sin(2 * np.pi * 96 * t) * np.exp(-t / 0.013), 0.0)
    t = secs(0.12)
    put(out, 0.12 * np.sin(2 * np.pi * 1730 * t) * np.exp(-t / 0.025), 0.006)
    put(out, 0.08 * np.sin(2 * np.pi * 2610 * t) * np.exp(-t / 0.02), 0.034)
    pop = high(noise(0.035, 7), 1400) * decay(0.035, 0.007)
    put(out, 0.35 * pop / np.max(np.abs(pop)), 0.004)
    return finish(out)


def camera_eject():
    """Baskının çıkışı: küçük motor vızlar, dişliler tıkırdar, kâğıt yuvadan kayıp düşer."""
    dur = 0.8
    t = secs(dur)
    f = 205 * (1 + 0.03 * np.sin(2 * np.pi * 7 * t)) * (1 - 0.06 * t)
    ph = np.cumsum(2 * np.pi * f / SR)
    saw = 2 * ((ph / (2 * np.pi)) % 1.0) - 1
    buzz = low(saw + 0.4 * np.sign(np.sin(2 * ph)), 2600)
    ticks = np.zeros(len(t))
    for k in np.arange(0, 0.66, 1 / 46.0):
        put(ticks, band(noise(0.006, int(k * 1000) + 11), 1200, 3200) * decay(0.006, 0.0015), k)
    motor = (0.55 * buzz + 0.5 * ticks) * adsr(dur, 0.03, 0.14)
    motor[int(0.68 * SR):] = 0
    slide = band(noise(0.5, 21), 2500, 7000) * 0.06 * np.linspace(0.3, 1.0, int(0.5 * SR))
    out = motor
    put(out, slide, 0.15)
    slap = low(noise(0.04, 23), 1800) * decay(0.04, 0.008)
    put(out, 0.6 * slap / np.max(np.abs(slap)), 0.69)
    return finish(out)


def _creak(dur, f0, f1, seed, formants, jitter=7.0):
    """Sürtünme gıcırtısı: yapış-kay darbeleri (frekansı yavaşça kayan bir nabız) tahtanın rezonanslarını çaldırır."""
    t = secs(dur)
    walk = np.cumsum(_rng(seed).standard_normal(len(t))) / np.sqrt(SR) * jitter
    walk = low(walk, 6.0, 1)
    f = np.linspace(f0, f1, len(t)) + 18 * np.sin(2 * np.pi * 1.1 * t + seed) + walk
    ph = np.cumsum(f / SR)
    pulses = np.zeros(len(t))
    idx = np.nonzero(np.diff(np.floor(ph)) > 0)[0]
    amps = 0.6 + 0.4 * _rng(seed + 1).random(len(idx))
    pulses[idx] = amps
    body = np.zeros(len(t))
    for fr, q, w in formants:
        r = reson(pulses, fr, q)
        body += w * r / (np.max(np.abs(r)) or 1.0)
    body += 0.03 * band(noise(dur, seed + 2), 1500, 4000)
    return body


def wood_creak():
    out = _creak(0.95, 125, 98, 5, [(430, 9, 1.0), (880, 10, 0.7), (1680, 12, 0.45), (2700, 8, 0.2)])
    return finish(out * adsr(0.95, 0.12, 0.25))


def door_open():
    """Kapı: mandal tıklar, menteşe uzun uzun gıcırdar, kanat havayı iter."""
    out = np.zeros(int(1.3 * SR))
    t = secs(0.08)
    latch = 0.5 * np.sin(2 * np.pi * 2380 * t) * np.exp(-t / 0.014) + 0.3 * np.sin(2 * np.pi * 3710 * t) * np.exp(-t / 0.009)
    put(out, latch, 0.0)
    clk = band(noise(0.01, 31), 2000, 7000) * decay(0.01, 0.002)
    put(out, 0.6 * clk / np.max(np.abs(clk)), 0.0)
    creak = _creak(1.0, 92, 168, 33, [(380, 11, 1.0), (760, 12, 0.6), (1420, 13, 0.4), (2350, 9, 0.2)])
    creak *= adsr(1.0, 0.18, 0.3)
    put(out, 0.9 * creak / np.max(np.abs(creak)), 0.14)
    sw = low(noise(1.0, 37), 500) * np.sin(np.linspace(0, np.pi, int(1.0 * SR))) ** 2
    put(out, 0.25 * sw / np.max(np.abs(sw)), 0.25)
    return finish(out)


def cloth():
    """Kumaş hışırtısı: dar bantlı gürültü, rastgele kısa kabarmalarla."""
    dur = 0.5
    base = band(noise(dur, 41), 900, 5200)
    g = np.zeros(len(base))
    r = _rng(43)
    for k in range(14):
        at = r.uniform(0.0, 0.38)
        w = r.uniform(0.02, 0.07)
        bump = np.hanning(int(w * SR)) * r.uniform(0.4, 1.0)
        put(g, bump, at)
    return finish(base * (0.15 + g) * adsr(dur, 0.02, 0.12))


def chop():
    """Balta tahtaya: keskin vuruş, tok gövde, kıymık çatırtısı."""
    out = np.zeros(int(0.42 * SR))
    hit = noise(0.005, 51) * decay(0.005, 0.0012)
    put(out, 1.0 * hit, 0.0)
    t = secs(0.3)
    for f, tau, a in [(162, 0.055, 0.8), (408, 0.03, 0.55), (975, 0.016, 0.35), (68, 0.04, 0.5)]:
        put(out, a * np.sin(2 * np.pi * f * t) * np.exp(-t / tau), 0.0005)
    crack = band(noise(0.04, 53), 2200, 7500) * decay(0.04, 0.009)
    put(out, 0.5 * crack / np.max(np.abs(crack)), 0.003)
    return finish(out)


def whistle():
    """İşaret düdüğü: iki ötüş, ikincisi titrek (düdüğün içindeki bilye)."""
    out = np.zeros(int(0.78 * SR))
    for at, dur, f0, trill in [(0.0, 0.27, 2380, 0.0), (0.36, 0.38, 2660, 0.45)]:
        t = secs(dur)
        f = f0 + 26 * np.sin(2 * np.pi * 7 * t)
        ph = np.cumsum(2 * np.pi * f / SR)
        tone = np.sin(ph) + 0.18 * np.sin(2 * ph)
        if trill:
            tone *= 1 - trill * (0.5 + 0.5 * np.sin(2 * np.pi * 29 * t))
        breath = band(noise(dur, int(at * 100) + 61), f0 * 0.8, f0 * 1.25) * 0.5
        put(out, (tone + breath) * adsr(dur, 0.018, 0.05), at)
    return finish(out)


def cough():
    """Öksürük: iki patlama; gırtlak sesi ağız boşluğunun üç rezonansından geçer."""
    out = np.zeros(int(0.62 * SR))
    for at, amp, shift, seed in [(0.0, 1.0, 1.0, 71), (0.23, 0.62, 0.92, 73)]:
        dur = 0.24
        t = secs(dur)
        env = (1 - np.exp(-t / 0.004)) * np.exp(-t / 0.055)
        src = noise(dur, seed) * env
        ph = np.cumsum(2 * np.pi * (118 * shift - 25 * t) / SR)
        src += 0.35 * (2 * ((ph / (2 * np.pi)) % 1.0) - 1) * env * np.exp(-t / 0.03)
        v = (1.0 * reson(src, 520 * shift, 4) + 0.6 * reson(src, 1380 * shift, 5) + 0.3 * reson(src, 2480 * shift, 6))
        v += 0.25 * low(src, 300)
        put(out, amp * v / np.max(np.abs(v)), at)
    return finish(out)


SOUNDS = {"camera": camera, "camera_eject": camera_eject, "wood_creak": wood_creak, "door_open": door_open,
          "cloth": cloth, "chop": chop, "whistle": whistle, "cough": cough}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("names", nargs="*", help="üretilecek sesler (boşsa hepsi): " + ", ".join(SOUNDS))
    ap.add_argument("--out", default=os.path.join(ROOT, "assets", "audio", "sfx"))
    a = ap.parse_args()
    names = a.names or list(SOUNDS)
    bad = [n for n in names if n not in SOUNDS]
    if bad:
        sys.exit("bilinmeyen ses: " + ", ".join(bad))
    os.makedirs(a.out, exist_ok=True)
    for n in names:
        x = SOUNDS[n]()
        path = os.path.join(a.out, n + ".ogg")
        sf.write(path, x, SR, format="OGG", subtype="VORBIS")
        print("%-13s %.2f sn → %s" % (n, len(x) / SR, path))


if __name__ == "__main__":
    main()
