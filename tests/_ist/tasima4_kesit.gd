extends SceneTree
## TAŞIMA-4 kesit sondası (kurulum yok): gedik ekseni boyunca (x = 0 ve verilen x'ler) peribolos → moloz → teras → hendek →
## ova zemin yüksekliği ve hendek geçişleri. Düello yaklaşma yolunu (ova → dolgu → teras → moloz sırtı) seçmek için.
##   godot --headless --path . -s tests/_ist/tasima4_kesit.gd
## Satırlar: KESIT4 ana=… | KESIT4 gecis=… | KESIT4 x=… z=… y=…


func _init() -> void:
	var sur := SurSet.yeni("mesoteikhion")
	print("KESIT4 ana gedik=%s moloz_sirti=%s dis_z0=%.2f dis_z1=%.2f teras=%s hendek=[%.2f..%.2f] dip=%.2f ova_y=%.2f ova_ofs=%s" % [
		sur.gedik(), sur.moloz_sirti(), sur.dis_sur_z0(), sur.dis_sur_z1(), sur.teras(), sur.hendek_z0(), sur.hendek_z1(),
		sur.hendek_dip_y(), sur.ova_y(), sur.ova_ofs()])
	for g: Dictionary in sur.gecisler():
		print("KESIT4 gecis=%s" % [g])
	for x: float in [0.0, -2.0, 2.0, -4.0, 4.0]:
		var z := sur.dis_sur_z0() - 4.0
		while z < sur.hendek_z1() + 8.0:
			print("KESIT4 x=%.1f z=%.1f y=%.2f" % [x, z, sur.zemin_y(x, z)])
			z += 1.0
	print("KESIT4 kosu=%s" % [sur.kosu_yolu(Vector3(0, sur.ova_y(), sur.hendek_z1() + 14.0), sur.moloz_sirti())])
	quit(0)
