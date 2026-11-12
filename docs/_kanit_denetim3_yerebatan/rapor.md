# Denetim 3 — Yerebatan Sarnıcı (44b) — ARA KAYIT (yarım)

Dal `wip/denetim3-yerebatan` (taban: `wip/0.99.119`). Godot 4.4.1 resmi linux x86_64.

## Ön bulgular (bitti)
- `python3 tests/check_keys.py` → `anahtar: 6888 sorun: 0`; `check_speakers.py` → `SPEAKERCHECK PASS`; `check_voice_rules.py` → `VOICERULES PASS (9783 anahtar, 0 sorun)`; `check_inline.py` → `INLINECHECK PASS (723 anahtar, 0 sorun)`; `tests/parse_check.tscn` → `PARSECHECK PASS scripts=250`.
- Ses: 74 anahtar × tr/en = 148 dosya, hepsi var (`ses_olcum.csv`). 0,4 sn'den kısa yok; tepe en yüksek −0,5 dB (D44B_N_COLLAPSE tr), 0 dBFS'ye yapışan yok; ort. ses < −40 dB olan yok.
- Devam edecek: otomatik test koşuları, ekranlı koşu + kareler, metin, oynanış, puan.
