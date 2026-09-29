extends GutTest

## Os 7 pontos da SPEC secao 6. O manifesto e o portao: se alguem mexer
## numa definicao e esquecer de rodar o gerador, o sha256 nao casa e a
## suite reprova.

const MANIFEST_PATH := "res://assets/sprites/manifest.json"
const DEFS_DIR := "res://tools/pixelart/sprite_defs/"

## Sprites que a cena da mesa exige. Crescer esta lista e como a cena
## declara o que precisa (SPEC secao 6, ponto 7).
const REQUIRED_SPRITES := [
	"desk_surface",
	"window_night",
	"microphone",
	"teleprompter_frame",
	"phone",
	"letter_stack",
	"notebook",
	"block_slot",
	"block_slot_quota",
	"listeners_dial",
	"desk_lamp",
	"on_air_sign",
	"phone_body",
	"letter_sheet",
	"official_sheet",
	"notebook_page",
	"bubble_them",
	"wax_seal",
	"stamp_ministry",
	"avatar_celia",
	"avatar_toledo",
	"avatar_mendes",
	"avatar_anonimo",
	"avatar_valvula",
	"avatar_ministerio",
]

var _sprites: Array = []


func before_all() -> void:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and parsed.has("sprites"):
		_sprites = parsed["sprites"]


func _definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	var dir := DirAccess.open(DEFS_DIR)
	if dir == null:
		return definitions
	var file_names := dir.get_files()
	file_names.sort()
	for file_name in file_names:
		if file_name.ends_with(".gd"):
			var script: GDScript = load(DEFS_DIR + file_name)
			definitions.append(script.definition())
	return definitions


## Pela textura importada, e nao por Image.load_from_file: ler o PNG cru
## de res:// funciona no editor e quebra no export, e o engine trata isso
## como erro — o que reprova o teste, corretamente.
func _image_of(path: String) -> Image:
	var texture: Texture2D = load(path)
	if texture == null:
		return null
	return texture.get_image()


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


# 1
func test_manifest_loads_and_is_not_empty() -> void:
	assert_true(FileAccess.file_exists(MANIFEST_PATH), "o manifesto deveria existir")
	assert_gt(_sprites.size(), 0, "o manifesto nao deveria estar vazio")


# 2
func test_every_manifest_path_exists_and_loads_as_texture() -> void:
	for sprite in _sprites:
		var path: String = sprite["path"]
		assert_true(ResourceLoader.exists(path), "PNG do manifesto nao existe: %s" % path)
		var texture: Texture2D = load(path)
		assert_not_null(texture, "deveria carregar como Texture2D: %s" % path)


# 3
func test_png_dimensions_match_the_manifest() -> void:
	for sprite in _sprites:
		var image := _image_of(sprite["path"])
		assert_not_null(image, "deveria abrir a imagem: %s" % sprite["path"])
		assert_eq(image.get_width(), int(sprite["width"]), "largura de %s" % sprite["name"])
		assert_eq(image.get_height(), int(sprite["height"]), "altura de %s" % sprite["name"])


# 4
func test_every_opaque_pixel_is_a_palette_color() -> void:
	var valid_keys := PixelPalette.all_color_keys()
	for sprite in _sprites:
		var image := _image_of(sprite["path"])
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x, y)
				if color.a == 0.0:
					continue
				assert_true(valid_keys.has(PixelPalette.color_key(color)),
					"cor fora da paleta em %s (%d,%d): #%s" % [
						sprite["name"], x, y, PixelPalette.color_key(color)])


# 5
func test_building_twice_gives_the_same_bytes() -> void:
	var definitions := _definitions()
	assert_gt(definitions.size(), 0, "deveria haver definicoes de sprite")
	for definition in definitions:
		var first := PixelSpriteBuilder.build(definition)
		var second := PixelSpriteBuilder.build(definition)
		assert_eq(first.get_data(), second.get_data(),
			"gerar duas vezes deveria dar o mesmo resultado: %s" % definition["name"])


func test_png_on_disk_matches_the_current_definition() -> void:
	# O portao de verdade: mexeu na definicao e nao rodou o gerador?
	var by_name := {}
	for sprite in _sprites:
		by_name[sprite["name"]] = sprite

	for definition in _definitions():
		var sprite_name := String(definition["name"])
		assert_true(by_name.has(sprite_name), "%s nao esta no manifesto" % sprite_name)
		if not by_name.has(sprite_name):
			continue
		var image := PixelSpriteBuilder.build(definition)
		assert_eq(_sha256(image.get_data()), String(by_name[sprite_name]["sha256"]),
			"%s esta fora de data: rode tools/pixelart/generate.gd" % sprite_name)


# 6
func test_every_definition_is_well_formed() -> void:
	var definitions := _definitions()
	assert_gt(definitions.size(), 0)
	for definition in definitions:
		assert_eq(PixelSpriteBuilder.validate(definition), "",
			"definicao mal formada: %s" % definition.get("name", "(sem nome)"))


# 7
func test_every_sprite_the_desk_scene_needs_is_in_the_manifest() -> void:
	var names := []
	for sprite in _sprites:
		names.append(sprite["name"])
	for required in REQUIRED_SPRITES:
		assert_true(names.has(required), "a mesa precisa do sprite '%s'" % required)


func test_nine_patch_margins_fit_inside_the_sprite() -> void:
	for sprite in _sprites:
		if not sprite.has("nine_patch"):
			continue
		var margin: int = int(sprite["nine_patch"])
		assert_gt(margin, 0, "margem de nine-patch de %s deveria ser positiva" % sprite["name"])
		assert_lt(margin * 2, int(sprite["width"]),
			"margens de %s nao cabem na largura" % sprite["name"])
		assert_lt(margin * 2, int(sprite["height"]),
			"margens de %s nao cabem na altura" % sprite["name"])


func test_sprite_names_are_unique() -> void:
	var seen := {}
	for sprite in _sprites:
		assert_false(seen.has(sprite["name"]), "nome de sprite repetido: %s" % sprite["name"])
		seen[sprite["name"]] = true
