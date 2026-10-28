#!/usr/bin/env python3
"""Seslendirmenin temel hızı: dosyalar kayıttan TEMPO kat hızlı saklanır (ffmpeg atempo, perde değişmez).

ElevenLabs okuması oyunda ağır kalıyordu. Oyundaki "Konuşma hızı" ayarı (GameState.voice_speed) bunun üstüne çarpan.
Her dosyanın hızı mp3 yorumuna yazılır (nhg_tempo=1.1): iki kez hızlanmaz, TEMPO değişirse yalnız fark uygulanır.
voice_gen.py her ürettiği dosyayı buradan geçirir.

    python3 tools/voice_tempo.py all              # bütün tr/en dosyaları (işlenmişleri atlar)
    python3 tools/voice_tempo.py check            # TEMPO'da olmayan dosyaları sayar
"""
import os, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

TEMPO = 1.1
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIRS = [os.path.join(ROOT, "assets/audio/voice", l) for l in ("tr", "en")]
TAG = "nhg_tempo="


def current(path: str) -> float:
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format_tags=comment", "-of", "csv=p=0", path],
                         capture_output=True, text=True).stdout.strip()
    return float(out[len(TAG):]) if out.startswith(TAG) else 1.0


def apply(path: str, tempo: float = TEMPO) -> bool:
    """Dosyayı TEMPO'ya getirir; değiştiyse True."""
    have = current(path)
    ratio = tempo / have
    if abs(ratio - 1.0) < 0.001:
        return False
    tmp = tempfile.mktemp(suffix=".mp3")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", path, "-af", f"atempo={ratio:.5f}",
                    "-map_metadata", "-1", "-metadata", f"comment={TAG}{tempo:g}",
                    "-ar", "44100", "-c:a", "libmp3lame", "-b:a", "128k", tmp], check=True)
    os.replace(tmp, path)
    return True


def files():
    for d in DIRS:
        for f in sorted(os.listdir(d)):
            if f.endswith(".mp3"):
                yield os.path.join(d, f)


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "check"
    fs = list(files())
    if cmd == "check":
        with ThreadPoolExecutor(os.cpu_count() or 4) as ex:
            bad = [f for f, t in zip(fs, ex.map(current, fs)) if abs(t - TEMPO) > 0.001]
        print(f"{len(fs)} dosya, {len(bad)} tanesi {TEMPO} hızında değil")
        for f in bad[:20]:
            print("  ", os.path.relpath(f, ROOT))
        sys.exit(1 if bad else 0)
    if cmd == "all":
        done = 0
        with ThreadPoolExecutor(os.cpu_count() or 4) as ex:
            for i, ch in enumerate(ex.map(apply, fs), 1):
                done += ch
                if i % 1000 == 0:
                    print(f"{i}/{len(fs)}", flush=True)
        print(f"Bitti: {done} dosya {TEMPO} hızına getirildi ({len(fs) - done} zaten öyleydi).")


if __name__ == "__main__":
    main()
