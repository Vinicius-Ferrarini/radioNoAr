extends SceneTree

## Gera os PNGs de assets/sprites/ e o manifesto, a partir das
## definições em tools/pixelart/sprite_defs/.
##
##   C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/generate.gd
##
## Determinístico por construção: ordem alfabética de nome, sem RNG, sem
## timestamp. Duas execuções seguidas não mudam um byte — e o teste de
## manifesto compara o sha256, então esquecer de regerar quebra a suíte.

const DEFS_DIR := "res://tools/pixelart/sprite_defs/"
const OUTPUT_DIR := "res://assets/sprites/"
const MANIFEST_PATH := OUTPUT_DIR + "manifest.json"


func _init() -> void:
	var definitions := _collect_definitions()
	if definitions.is_empty():
		printerr("nenhuma definição de sprite encontrada em %s" % DEFS_DIR)
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))

	var entries: Array = []
	var failures := 0

	for definition in definitions:
		var error := PixelSpriteBuilder.validate(definition)
		if not error.is_empty():
			printerr("  [x] %s" % error)
			failures += 1
			continue

		var image := PixelSpriteBuilder.build(definition)
		var sprite_name := String(definition["name"])
		var path := OUTPUT_DIR + sprite_name + ".png"

		var save_error := image.save_png(path)
		if save_error != OK:
			printerr("  [x] falha ao gravar %s (erro %d)" % [path, save_error])
			failures += 1
			continue

		entries.append(_manifest_entry(definition, image, path))
		print("  [ok] %s  %dx%d" % [sprite_name, image.get_width(), image.get_height()])

	if failures > 0:
		printerr("%d sprite(s) falharam; manifesto não foi escrito." % failures)
		quit(1)
		return

	_write_manifest(entries)
	print("%d sprites em %s" % [entries.size(), OUTPUT_DIR])
	quit(0)


## Em ordem alfabética de arquivo, que é a mesma do nome: sem isso o
## manifesto mudaria de ordem entre execuções.
func _collect_definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	var dir := DirAccess.open(DEFS_DIR)
	if dir == null:
		return definitions

	var file_names := dir.get_files()
	file_names.sort()

	for file_name in file_names:
		if not file_name.ends_with(".gd"):
			continue
		var script: GDScript = load(DEFS_DIR + file_name)
		if script == null or not script.has_method("definition"):
			printerr("  [x] %s não expõe definition()" % file_name)
			continue
		definitions.append(script.definition())

	return definitions


func _manifest_entry(definition: Dictionary, image: Image, path: String) -> Dictionary:
	var entry := {
		"name": String(definition["name"]),
		"path": path,
		"width": image.get_width(),
		"height": image.get_height(),
		"sha256": _sha256(image.get_data()),
		"palette": _palette_of(image),
	}
	if definition.has("nine_patch"):
		entry["nine_patch"] = int(definition["nine_patch"])
	return entry


## Os nomes de cor que o sprite usa de fato, em ordem alfabética. Serve
## para revisar a arte sem abrir o PNG.
func _palette_of(image: Image) -> Array:
	var keys_to_names := {}
	for color_name in PixelPalette.HEX:
		keys_to_names[PixelPalette.HEX[color_name]] = color_name

	var used := {}
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a == 0.0:
				continue
			var key := PixelPalette.color_key(color)
			if keys_to_names.has(key):
				used[keys_to_names[key]] = true

	var names := used.keys()
	names.sort()
	return names


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _write_manifest(entries: Array) -> void:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	if file == null:
		printerr("não foi possível escrever %s" % MANIFEST_PATH)
		return
	file.store_string(JSON.stringify({"sprites": entries}, "\t", true) + "\n")
	file.close()
