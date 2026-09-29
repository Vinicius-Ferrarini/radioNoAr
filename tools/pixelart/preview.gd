extends SceneTree

## Imprime um sprite como texto no terminal, para conferir a arte sem
## abrir o editor.
##
##   ...Godot.exe --headless -s tools/pixelart/preview.gd -- window_night
##
## Sem argumento, lista os sprites disponiveis. Cada cor da paleta vira
## um caractere; a legenda sai embaixo.

const DEFS_DIR := "res://tools/pixelart/sprite_defs/"
const RAMP := "abcdefghijklmnopqrstuvwxyz0123456789"


func _init() -> void:
	var names := _available()
	var wanted := ""
	for argument in OS.get_cmdline_user_args():
		wanted = argument

	if wanted.is_empty():
		print("sprites: %s" % ", ".join(names))
		quit(0)
		return

	if not names.has(wanted):
		printerr("sprite desconhecido: %s" % wanted)
		quit(1)
		return

	_print_sprite(wanted)
	quit(0)


func _available() -> PackedStringArray:
	var names := PackedStringArray()
	var dir := DirAccess.open(DEFS_DIR)
	if dir == null:
		return names
	var file_names := dir.get_files()
	file_names.sort()
	for file_name in file_names:
		if file_name.ends_with(".gd"):
			names.append(file_name.trim_suffix(".gd"))
	return names


func _print_sprite(sprite_name: String) -> void:
	var script: GDScript = load(DEFS_DIR + sprite_name + ".gd")
	var definition: Dictionary = script.definition()
	var image := PixelSpriteBuilder.build(definition)
	if image == null:
		quit(1)
		return

	var keys_to_names := {}
	for color_name in PixelPalette.HEX:
		keys_to_names[PixelPalette.HEX[color_name]] = color_name

	var character_of := {}
	var legend: Array[String] = []

	print("%s  %dx%d" % [sprite_name, image.get_width(), image.get_height()])
	for y in image.get_height():
		var line := ""
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a == 0.0:
				line += "."
				continue
			var key := PixelPalette.color_key(color)
			if not character_of.has(key):
				var character := RAMP[character_of.size() % RAMP.length()]
				character_of[key] = character
				legend.append("%s = %s" % [character, keys_to_names.get(key, "#" + key)])
			line += character_of[key]
		print(line)

	print("")
	for entry in legend:
		print("  %s" % entry)
