# Çizim bütçesi

tests/perf_run.sh ile ölçülür (varsayılan kalite, 1280×720, test botu). Bütçe: karede 6000 çizim, 5 M üçgen.
Ortanca: sahnenin olağan hâli; en yüksek: en ağır an. Üçgenler bin (k).

| Sahne | Ölçüm | Çizim ort. | Çizim en yüksek | Üçgen ort. (k) | Üçgen en yüksek (k) | Gölge payı | Bütçe |
|---|---:|---:|---:|---:|---:|---:|---|
| chapter26 | 11 | 12853 | 14630 | 12760 | 15599 | 46% | AŞIYOR |
| chapter0 | 4 | 9140 | 13031 | 11700 | 14637 | 27% | AŞIYOR |
| chapter20 | 23 | 10612 | 10916 | 11034 | 11320 | 35% | AŞIYOR |
| chapter25 | 8 | 8294 | 13484 | 6451 | 10671 | 19% | AŞIYOR |
| chapter24 | 9 | 4597 | 7715 | 4810 | 9299 | 14% | tamam |
| chapter10g | 5 | 7854 | 9711 | 2827 | 8837 | 32% | AŞIYOR |
| chapter2 | 12 | 5603 | 7680 | 6224 | 8760 | 18% | AŞIYOR |
| chapter27 | 7 | 4404 | 8784 | 2281 | 8534 | 38% | tamam |
| chapter30o | 20 | 3005 | 6928 | 2439 | 8421 | 27% | tamam |
| chapter17o | 6 | 1834 | 7026 | 1673 | 8374 | 18% | tamam |
| chapter42b | 31 | 2993 | 5207 | 6069 | 8297 | 9% | AŞIYOR |
| chapter43o | 55 | 2351 | 9731 | 2405 | 8245 | 26% | tamam |
| chapter29o | 34 | 2799 | 6977 | 1980 | 8189 | 25% | tamam |
| chapter22 | 8 | 6758 | 7243 | 7686 | 8185 | 26% | AŞIYOR |
| chapter39o | 26 | 5610 | 6852 | 6089 | 8112 | 13% | AŞIYOR |
| chapter26o | 13 | 8826 | 10738 | 6826 | 8047 | 36% | AŞIYOR |
| chapter19 | 12 | 1260 | 6757 | 633 | 8041 | 9% | tamam |
| chapter18 | 4 | 5804 | 6589 | 7664 | 7989 | 6% | AŞIYOR |
| chapter9 | 4 | 5344 | 7124 | 6223 | 7913 | 34% | AŞIYOR |
| chapter31o | 35 | 2136 | 9394 | 2416 | 7706 | 14% | tamam |
| chapter10z | 9 | 3664 | 6890 | 5523 | 7698 | 33% | AŞIYOR |
| chapter29 | 12 | 6159 | 6949 | 7001 | 7693 | 6% | AŞIYOR |
| chapter17 | 75 | 777 | 8471 | 563 | 7674 | 42% | tamam |
| chapter36b | 17 | 4946 | 6904 | 5590 | 7600 | 19% | AŞIYOR |
| chapter11 | 3 | 5294 | 9178 | 6884 | 7483 | 27% | AŞIYOR |
| chapter12b | 5 | 7169 | 7989 | 6828 | 7321 | 14% | AŞIYOR |
| chapter38o | 31 | 2737 | 6409 | 2623 | 7303 | 23% | tamam |
| chapter7 | 5 | 4475 | 6459 | 4791 | 7227 | 45% | tamam |
| chapter30 | 21 | 3322 | 5379 | 4195 | 6870 | 16% | tamam |
| chapter10b | 7 | 3401 | 6451 | 3755 | 6746 | 26% | tamam |
| chapter22o | 31 | 7517 | 9714 | 4901 | 6568 | 45% | AŞIYOR |
| chapter16 | 3 | 788 | 5502 | 163 | 6425 | 39% | tamam |
| chapter10h | 6 | 2803 | 6846 | 2624 | 6112 | 38% | tamam |
| chapter37o | 30 | 5270 | 7056 | 3707 | 5669 | 33% | tamam |
| chapter20o | 50 | 4690 | 6224 | 4087 | 5133 | 31% | tamam |
| chapter24o | 7 | 3157 | 4793 | 3888 | 4937 | 41% | tamam |
| chapter23 | 5 | 3376 | 3437 | 4391 | 4689 | 32% | tamam |
| chapter6 | 3 | 3553 | 4172 | 3890 | 4634 | 40% | tamam |
| chapter18b | 11 | 1836 | 3267 | 1208 | 3933 | 24% | tamam |
| chapter32o | 34 | 5107 | 6241 | 2963 | 3927 | 24% | tamam |
| chapter41o | 47 | 3178 | 4052 | 2676 | 3354 | 16% | tamam |
| chapter28o | 16 | 2856 | 3536 | 2603 | 3271 | 10% | tamam |
| chapter21 | 11 | 2305 | 2813 | 2212 | 2890 | 22% | tamam |
| chapter10 | 4 | 2452 | 2993 | 2189 | 2705 | 31% | tamam |
| chapter4 | 3 | 2555 | 4045 | 1763 | 2345 | 52% | tamam |
| chapter19o | 31 | 1063 | 2468 | 656 | 2266 | 34% | tamam |
| chapter34o | 87 | 1658 | 2790 | 694 | 1717 | 67% | tamam |
| chapter35o | 74 | 2527 | 3746 | 1096 | 1497 | 54% | tamam |
| chapter33o | 46 | 2061 | 2678 | 834 | 1425 | 62% | tamam |
| chapter14 | 2 | 3604 | 3624 | 849 | 871 | 11% | tamam |
| chapter1 | 7 | 876 | 1987 | 332 | 742 | 76% | tamam |
| chapter15 | 3 | 781 | 877 | 518 | 527 | 65% | tamam |
| chapter3 | 18 | 937 | 1105 | 188 | 388 | 43% | tamam |
| chapter10a | 7 | 796 | 921 | 97 | 171 | 0% | tamam |
| chapter12 | 6 | 693 | 1043 | 145 | 148 | 0% | tamam |
| chapter21o | 11 | 484 | 609 | 91 | 136 | 0% | tamam |
| chapter5 | 4 | 982 | 1857 | 80 | 114 | 67% | tamam |
| chapter10l | 7 | 489 | 704 | 106 | 107 | 0% | tamam |
| chapter13 | 4 | 738 | 810 | 75 | 107 | 66% | tamam |
| chapter8 | 6 | 726 | 1305 | 65 | 78 | 28% | tamam |

60 sahne ölçüldü, 18 tanesi bütçeyi (ortancada) aşıyor.
