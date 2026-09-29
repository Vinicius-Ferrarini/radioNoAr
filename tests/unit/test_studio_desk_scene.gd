extends GutTest

## A mesa do estudio: monta, cabe na tela e nao usa nada proibido.

const SCENE_PATH := "res://scenes/studio_desk.tscn"
const VIEWPORT := Vector2i(320, 180)

## Os nos que a mesa promete ter (GAME_DESIGN secao 12).
const EXPECTED_NODES := [
	"Background",
	"DeskBand",
	"Window",
	"OnAirSign",
	"DeskLamp",
	"ListenersDial",
	"Microphone",
	"Teleprompter",
	"Phone",
	"LetterStack",
	"Notebook",
	"Block1",
	"Block2",
	"Block3",
	"Block4",
]

var _root: Control


func before_each() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	_root = scene.instantiate()
	add_child_autofree(_root)


func test_scene_instantiates_as_a_control() -> void:
	assert_not_null(_root, "a cena deveria instanciar")
	assert_true(_root is Control, "a raiz da UI e um Control")


func test_every_promised_node_is_there() -> void:
	for node_name in EXPECTED_NODES:
		assert_not_null(_root.get_node_or_null(node_name), "falta o no '%s'" % node_name)


func test_every_texture_slot_is_filled() -> void:
	var checked := 0
	for node in _all_nodes(_root):
		if node is TextureRect:
			assert_not_null(node.texture, "TextureRect sem textura: %s" % node.name)
			checked += 1
		elif node is NinePatchRect:
			assert_not_null(node.texture, "NinePatchRect sem textura: %s" % node.name)
			checked += 1
	assert_gt(checked, 0, "deveria haver sprites na mesa")


func test_everything_fits_inside_the_viewport() -> void:
	# 320x180 e apertado de proposito (ADR 0005). Se algo nao couber, e
	# melhor descobrir aqui do que abrindo o jogo.
	for node in _all_nodes(_root):
		if not (node is TextureRect or node is NinePatchRect):
			continue
		var rect: Rect2 = node.get_rect()
		assert_gte(rect.position.x, 0.0, "%s sai pela esquerda" % node.name)
		assert_gte(rect.position.y, 0.0, "%s sai por cima" % node.name)
		assert_lte(rect.end.x, float(VIEWPORT.x), "%s sai pela direita" % node.name)
		assert_lte(rect.end.y, float(VIEWPORT.y), "%s sai por baixo" % node.name)


func test_sprites_are_not_stretched_out_of_proportion() -> void:
	# TextureRect com tamanho diferente da textura significa pixel
	# esticado. Nine-patch pode esticar: e para isso que serve.
	for node in _all_nodes(_root):
		if not (node is TextureRect):
			continue
		var texture_size: Vector2 = node.texture.get_size()
		assert_eq(node.size, texture_size,
			"%s deveria ter o tamanho exato da textura" % node.name)


func test_the_quota_block_is_the_one_with_the_dashed_frame() -> void:
	var quota_block: NinePatchRect = _root.get_node("Block1")
	assert_true(String(quota_block.texture.resource_path).contains("block_slot_quota"),
		"o bloco de cota usa a moldura tracejada")

	for block_name in ["Block2", "Block3", "Block4"]:
		var block: NinePatchRect = _root.get_node(block_name)
		assert_false(String(block.texture.resource_path).contains("quota"),
			"%s nao e bloco de cota" % block_name)


func test_the_four_program_blocks_are_side_by_side_and_do_not_overlap() -> void:
	var previous_end := -1.0
	for block_name in ["Block1", "Block2", "Block3", "Block4"]:
		var block: Control = _root.get_node(block_name)
		assert_gt(block.position.x, previous_end, "%s encosta no bloco anterior" % block_name)
		previous_end = block.position.x + block.size.x


func test_no_node_uses_custom_draw() -> void:
	for node in _all_nodes(_root):
		assert_false(node.has_method("_draw"), "%s nao pode ter _draw()" % node.name)


func _all_nodes(from: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in from.get_children():
		nodes.append(child)
		nodes.append_array(_all_nodes(child))
	return nodes
