extends "res://tests/_ist/bakis_kare.gd"
## G18: bakis_kare'nin hub'ı bekleyen eşi. `sonda=` ve `bak=` hub bölümlerinde (10h, 12b, 13, 23, 24, 6, 7) hub kurulmadan
## (13: büro sahnesinden sonra; 6/7: akışın içinde) çalışırsa yanlış dünyayı ölçer. Burada önce hub beklenir:
## IstBaglama.aktif_bolge == "byz_walls" ve sahnede "SurHub" düğümü (en çok 120 sn; yoksa GOZ18_HUB_YOK satırı ve
## yine de ölçülür). hub=0: beklemeden (8y, 31o, 18b, 25, 36b … bakis_kare ile aynı).
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/goz18_sonda.tscn -- \
##     bolum=10h sonda=30,5.9,58,5.9 [bak=31,1.6,5.9,90 shots=KLASÖR] [cesit=byz] [hub=0]
## Satırlar: GOZ18_HUB t=… · BAKIS_SONDA … · BAKIS_TAMBOY … · BAKIS_BITTI

var hub_bekle := true


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "hub":
			hub_bekle = kv[1] != "0"
	super._ready()


func _hub_bekle() -> void:
	if not hub_bekle:
		return
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 120000:
		if IstBaglama.aktif_bolge == "byz_walls" and get_tree().root.find_child("SurHub", true, false) != null:
			print("GOZ18_HUB t=%.1f" % ((Time.get_ticks_msec() - t0) / 1000.0))
			return
		await get_tree().process_frame
	print("GOZ18_HUB_YOK bolum=%s bolge=%s" % [bolum, IstBaglama.aktif_bolge])


func _sonda() -> void:
	await _hub_bekle()
	await super._sonda()
	if bak == "":
		_bitir("sonda")


func _tam_boy() -> void:
	if sonda == "":
		await _hub_bekle()
	await super._tam_boy()
