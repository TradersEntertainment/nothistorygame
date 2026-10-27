class_name Handover
## Eşya elden ele (Bölüm 6 ve 9'daki yardımcıların ortak hâli): karşıdakinin elinden Tolga'ya (take_from), Tolga'dan
## karşıdakinin eline (pass_to). Karşıdaki Person ya da Soldier olabilir (ikisinin de rig'i var). Otomatik testte
## (PACE dışında) anında geçer.


static func instant() -> bool:
	return GameState.autotest and not GameState.pace


## Eşya elden ele geçerken arada kol boyundan uzun mesafe varsa kayda yazar (Bölüm 12'de 6 m havada uçuyordu):
## uzaktakine biri taşır ya da veren yaklaşır.
const FLY_MAX := 2.2


static func audit_distance(n: Node, from: Vector3, to: Vector3) -> void:
	var d := from.distance_to(to)
	if d > FLY_MAX and n.is_inside_tree():
		var sc := n.get_tree().current_scene
		print("WARN_FLY_ITEM %s d=%.1f who=%s" % [sc.scene_file_path.get_file() if sc else "?", d, n.name])


static func wait(n: Node, s: float) -> void:
	if instant() or not n.is_inside_tree():
		await n.get_tree().process_frame
		return
	await n.get_tree().create_timer(s, false).timeout      # duraklatmada beklemez


static func rig_of(node: Node) -> Rig:
	if node == null:
		return null
	var r = node.get("rig")
	return r as Rig if r is Rig else null


## Karşıdaki eşyayı uzatır, Tolga alır: önce onun elinde görünür, Tolga'ya doğru gelir, sonra Tolga'nın elinde
## (player.show_prop kind). scene: modelin geçerken bağlanacağı düğüm (bölüm sahnesi).
static func take_from(scene: Node3D, player: Player, node: Node3D, model: Node3D, kind: String, hold := 1.8) -> void:
	var rg := rig_of(node)
	if rg and not instant():
		rg.hold_item(model, false, false)
		await wait(scene, 0.9)
		if is_instance_valid(model) and model.get_parent():
			var gt := model.global_transform
			model.get_parent().remove_child(model)
			scene.add_child(model)
			model.global_transform = gt
			rg.release_item()
			var tw := scene.create_tween()
			var dest := player.camera.global_transform * Vector3(0.0, -0.25, -0.8)
			audit_distance(node, gt.origin, dest)
			tw.tween_property(model, "global_position", dest, 0.4).set_trans(Tween.TRANS_SINE)
			await tw.finished
	elif rg:
		rg.release_item()
	if is_instance_valid(model):
		model.queue_free()
	Audio.sfx("cloth" if kind in ["kaftan", "apron"] else "newspaper", -12.0, 1.3)
	player.show_prop(kind, hold)
	# Eşya geri çekilmeden sonraki iş başlamasın (kaftan: giyinme görüntüsünde kutu yüzün önünde kalıyordu)
	await wait(scene, maxf(1.0, hold + 0.7) if kind == "kaftan" else 1.0)


## Tolga eşyayı uzatır, karşıdakinin eline geçer ve orada kalır (bırakmak için release).
static func pass_to(scene: Node3D, player: Player, node: Node3D, model: Node3D) -> void:
	# Uzanan elde telefon/kumanda görünmesin (bir el iki şey tutmaz): el geri çekilince çıkar
	player._stow(true)
	scene.get_tree().create_timer(0.05 if instant() else 1.1, false).timeout.connect(player._stow.bind(false))
	player.hand_gesture("show")
	var from := player.camera.global_transform * Vector3(0.05, -0.2, -0.6)
	if node is Person:
		await (node as Person).receive_item(model, from)
		return
	var rg := rig_of(node)
	if rg == null:
		model.queue_free()
		return
	scene.add_child(model)
	model.global_position = from
	audit_distance(node, from, node.global_position + Vector3(0, 1.25, 0))
	var tw := scene.create_tween()
	tw.tween_property(model, "global_position", node.global_position + Vector3(0, 1.25, 0) + node.global_transform.basis.z * 0.35,
			0.05 if instant() else 0.45).set_trans(Tween.TRANS_SINE)
	await tw.finished
	rg.hold_item(model)


static func release(node: Node3D) -> void:
	var rg := rig_of(node)
	if rg:
		rg.release_item()


## Çanta eşyasının modeli, ele sığacak boyda.
static func item_model(id: String) -> Node3D:
	var m := Items.build(id)
	m.scale = Vector3.ONE * 0.6
	return m


## Mühürlü mektup: katlanmış kâğıt, kırmızı mühür.
static func letter_model() -> Node3D:
	var n := Node3D.new()
	Props.box(n, Vector3(0.22, 0.14, 0.006), Vector3.ZERO, Color("efe2c4"))
	Props.cyl(n, 0.022, 0.008, Vector3(0, -0.01, 0.005), Color("a8182a"), Vector3(90, 0, 0), 12)
	Props.strip_outlines(n)
	return n


## Katlanmış kaftan: kırmızı kumaş, altın şeritli.
static func kaftan_model() -> Node3D:
	var n := Node3D.new()
	Props.box(n, Vector3(0.34, 0.08, 0.26), Vector3.ZERO, Color("8a2b22"))
	for z in [-0.1, 0.1]:
		Props.box(n, Vector3(0.35, 0.082, 0.025), Vector3(0, 0, z), Color("d8a840"))
	Props.strip_outlines(n)
	return n


## Büro formu: gri başlıklı, satırlı kâğıt (Form Z-1, "toprak altında kalma formu").
static func form_model() -> Node3D:
	var n := Node3D.new()
	Props.box(n, Vector3(0.21, 0.29, 0.004), Vector3.ZERO, Color("f4f1ea"))
	Props.box(n, Vector3(0.21, 0.035, 0.005), Vector3(0, 0.12, 0.0005), Color("5a6470"))
	for k in 6:
		Props.box(n, Vector3(0.16, 0.004, 0.005), Vector3(-0.01, 0.06 - k * 0.03, 0.0005), Color("8a8f98"))
	Props.strip_outlines(n)
	return n
