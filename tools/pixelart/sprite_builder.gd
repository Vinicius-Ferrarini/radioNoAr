class_name PixelSpriteBuilder
extends RefCounted

## Transforma uma definição de sprite (dados) numa Image. Puro: não lê
## nem escreve disco, para o teste poder chamá-lo direto.
##
## Uma definição aceita duas formas, que podem conviver no mesmo sprite:
##
##   "rows"       — mapa literal de pixels, um caractere por pixel, com
##                  uma "legend" de caractere -> nome de cor da paleta.
##   "primitives" — lista de operações (rect, frame, line, pixels,
##                  dither), aplicadas na ordem em que aparecem.
##
## Quando as duas existem, o mapa vem primeiro e as primitivas desenham
## por cima.

const TRANSPARENT := Color(0, 0, 0, 0)
const SOURCE_SCALE := 2


## Devolve "" quando a definição está bem formada, ou a descrição do
## problema. O gerador e o teste usam a mesma checagem.
static func validate(definition: Dictionary) -> String:
	if not definition.has("name") or String(definition["name"]).is_empty():
		return "definição sem 'name'"
	if not definition.has("size"):
		return "%s: sem 'size'" % definition["name"]

	var size: Vector2i = definition["size"]
	if size.x <= 0 or size.y <= 0:
		return "%s: tamanho inválido %s" % [definition["name"], size]

	if definition.has("rows"):
		var rows: PackedStringArray = definition["rows"]
		if rows.size() != size.y:
			return "%s: %d linhas para altura %d" % [definition["name"], rows.size(), size.y]
		for i in rows.size():
			if rows[i].length() != size.x:
				return "%s: linha %d tem %d colunas, esperado %d" % [
					definition["name"], i, rows[i].length(), size.x]

		var legend: Dictionary = definition.get("legend", {})
		for i in rows.size():
			for character in rows[i]:
				if not legend.has(character):
					return "%s: caractere '%s' não está na legenda" % [definition["name"], character]
				var color_name: String = legend[character]
				if color_name != PixelPalette.NONE and not PixelPalette.has_color(color_name):
					return "%s: cor '%s' não está na paleta" % [definition["name"], color_name]

	for primitive in definition.get("primitives", []):
		var error := _validate_primitive(definition["name"], primitive)
		if not error.is_empty():
			return error
	for primitive in definition.get("source_details", []):
		var error := _validate_primitive(definition["name"], primitive)
		if not error.is_empty():
			return error

	return ""


static func build(definition: Dictionary) -> Image:
	var error := validate(definition)
	if not error.is_empty():
		push_error("sprite inválido: %s" % error)
		return null

	var size: Vector2i = definition["size"]
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(TRANSPARENT)

	if definition.has("rows"):
		_paint_rows(image, definition)

	for primitive in definition.get("primitives", []):
		_paint_primitive(image, primitive)

	# A definição continua no grid lógico conhecido. A fonte exportada tem
	# densidade 2x; detalhes opcionais são desenhados depois da ampliação e
	# portanto podem usar um único pixel do novo canvas.
	image.resize(size.x * SOURCE_SCALE, size.y * SOURCE_SCALE, Image.INTERPOLATE_NEAREST)
	for primitive in definition.get("source_details", []):
		_paint_primitive(image, primitive)

	return image


static func _paint_rows(image: Image, definition: Dictionary) -> void:
	var rows: PackedStringArray = definition["rows"]
	var legend: Dictionary = definition["legend"]
	for y in rows.size():
		var row := rows[y]
		for x in row.length():
			var color_name: String = legend[row[x]]
			if color_name == PixelPalette.NONE:
				continue
			image.set_pixel(x, y, PixelPalette.get_color(color_name))


static func _paint_primitive(image: Image, primitive: Dictionary) -> void:
	var color := PixelPalette.get_color(primitive.get("color", PixelPalette.NONE))

	match String(primitive["op"]):
		"rect":
			_fill_rect(image, primitive["x"], primitive["y"], primitive["w"], primitive["h"], color)
		"frame":
			var x: int = primitive["x"]
			var y: int = primitive["y"]
			var w: int = primitive["w"]
			var h: int = primitive["h"]
			_fill_rect(image, x, y, w, 1, color)
			_fill_rect(image, x, y + h - 1, w, 1, color)
			_fill_rect(image, x, y, 1, h, color)
			_fill_rect(image, x + w - 1, y, 1, h, color)
		"line":
			var x1: int = primitive["x1"]
			var y1: int = primitive["y1"]
			var x2: int = primitive["x2"]
			var y2: int = primitive["y2"]
			if y1 == y2:
				_fill_rect(image, mini(x1, x2), y1, absi(x2 - x1) + 1, 1, color)
			else:
				_fill_rect(image, x1, mini(y1, y2), 1, absi(y2 - y1) + 1, color)
		"pixels":
			for point in primitive["points"]:
				_set_pixel(image, point.x, point.y, color)
		"dither":
			var step: int = primitive.get("step", 2)
			var offset: int = primitive.get("offset", 0)
			for y in range(primitive["y"], primitive["y"] + primitive["h"]):
				for x in range(primitive["x"], primitive["x"] + primitive["w"]):
					if (x + y + offset) % step == 0:
						_set_pixel(image, x, y, color)


static func _validate_primitive(sprite_name: String, primitive: Dictionary) -> String:
	if not primitive.has("op"):
		return "%s: primitiva sem 'op'" % sprite_name

	var op := String(primitive["op"])
	const REQUIRED := {
		"rect": ["x", "y", "w", "h"],
		"frame": ["x", "y", "w", "h"],
		"line": ["x1", "y1", "x2", "y2"],
		"pixels": ["points"],
		"dither": ["x", "y", "w", "h"],
	}
	if not REQUIRED.has(op):
		return "%s: primitiva desconhecida '%s'" % [sprite_name, op]
	for key in REQUIRED[op]:
		if not primitive.has(key):
			return "%s: primitiva '%s' sem '%s'" % [sprite_name, op, key]

	var color_name: String = primitive.get("color", PixelPalette.NONE)
	if not PixelPalette.has_color(color_name):
		return "%s: cor '%s' não está na paleta" % [sprite_name, color_name]

	if op == "line" and primitive["x1"] != primitive["x2"] and primitive["y1"] != primitive["y2"]:
		return "%s: 'line' só aceita horizontal ou vertical" % sprite_name

	return ""


static func _fill_rect(image: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for py in range(y, y + h):
		for px in range(x, x + w):
			_set_pixel(image, px, py, color)


## Desenhar fora da imagem é silenciosamente ignorado: a definição é
## dado, e recortar é mais útil do que estourar.
static func _set_pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
