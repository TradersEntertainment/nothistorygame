extends SceneTree
## assets/art altındaki SVG'leri tek bir önizleme PNG'sinde toplar.
## Kullanım: godot --headless --path . --script res://tools/contact_sheet.gd -- ÇIKTI.png

func _init() -> void:
	var out: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "user://sheet.png"
	var files: Array[String] = []
	for dir in ["res://assets/art/portraits", "res://assets/art/icons", "res://assets/art/posters"]:
		for f in DirAccess.get_files_at(dir):
			if f.ends_with(".svg"):
				files.append(dir.path_join(f))
	var cell := 200
	var cols := 6
	var rows := int(ceil(files.size() / float(cols)))
	var sheet := Image.create(cols * cell, rows * cell, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("3b4150"))
	for i in files.size():
		var img := Image.new()
		var err := img.load_svg_from_string(FileAccess.get_file_as_string(files[i]), 1.0)
		if err != OK:
			printerr("SVG okunamadı: ", files[i])
			continue
		var s := float(cell - 16) / maxf(img.get_width(), img.get_height())
		img.resize(int(img.get_width() * s), int(img.get_height() * s), Image.INTERPOLATE_BILINEAR)
		img.convert(Image.FORMAT_RGBA8)
		var pos := Vector2i((i % cols) * cell + 8, (i / cols) * cell + 8)
		sheet.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), pos)
	sheet.save_png(out)
	print("sheet: ", out, " (", files.size(), " dosya)")
	quit()
