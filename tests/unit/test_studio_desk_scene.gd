extends GutTest

## A mesa do estudio: monta, cabe na tela, nao usa nada proibido, e a
## triagem/escalacao funciona de ponta a ponta pela interface.

const SCENE_PATH := "res://scenes/studio_desk.tscn"
const VIEWPORT := Vector2i(320, 180)

## Os nos que a mesa promete ter (GAME_DESIGN secao 12).
const EXPECTED_NODES := [
	"Background",
	"DeskBand",
	"Studio/Window",
	"Studio/OnAirSign",
	"Studio/DeskLamp",
	"Studio/ListenersDial",
	"Studio/Teleprompter",
	"Studio/Microphone",
	"Phone",
	"LetterStack",
	"Notebook",
	"Header/NightLabel",
	"Header/QuotaLabel",
	"Header/AudienceLabel",
	"Header/GoOnAirButton",
	"WorkPanel/InboxScroll/InboxList",
	"WorkPanel/NotebookView/NotebookList",
	"WorkPanel/ItemView/ClaimsList",
	"WorkPanel/BlockView/FramingScroll/FramingList",
	"WorkPanel/Feedback",
	"Blocks/Block1",
	"Blocks/Block2",
	"Blocks/Block3",
	"Blocks/Block4",
]

var _root: Control


func before_each() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	_root = scene.instantiate()
	add_child_autofree(_root)
	await get_tree().process_frame


func after_each() -> void:
	# A cena reconstroi listas com queue_free; sem esperar um quadro, o
	# GUT conta as linhas pendentes como orfas.
	await get_tree().process_frame
	await get_tree().process_frame


func after_all() -> void:
	# A cena inicia uma campanha no _ready; devolve o autoload ao estado
	# que os testes da v0 esperam.
	GameState.load_events()
	GameState.reset_run()


func _blocks() -> Array[Node]:
	return _root.get_node("Blocks").get_children()


func _inbox_rows() -> Array[Node]:
	return _root.get_node("WorkPanel/InboxScroll/InboxList").get_children()


func _drop_on_block(block_index: int, item_id: String) -> void:
	var block: Control = _blocks()[block_index]
	block._drop_data(Vector2.ZERO, {"kind": "inbox_item", "item_id": item_id})


# --- montagem ---

func test_scene_instantiates_as_a_control() -> void:
	assert_true(_root is Control, "a raiz da UI e um Control")


func test_every_promised_node_is_there() -> void:
	for node_path in EXPECTED_NODES:
		assert_not_null(_root.get_node_or_null(node_path), "falta o no '%s'" % node_path)


func test_every_texture_slot_is_filled() -> void:
	var checked := 0
	for node in _all_nodes(_root):
		if node is TextureRect or node is NinePatchRect:
			assert_not_null(node.texture, "sem textura: %s" % node.name)
			checked += 1
	assert_gt(checked, 0, "deveria haver sprites na mesa")


func test_everything_fits_inside_the_viewport() -> void:
	for node in _all_nodes(_root):
		if not (node is TextureRect or node is NinePatchRect):
			continue
		var rect: Rect2 = node.get_global_rect()
		assert_gte(rect.position.x, 0.0, "%s sai pela esquerda" % node.name)
		assert_gte(rect.position.y, 0.0, "%s sai por cima" % node.name)
		assert_lte(rect.end.x, float(VIEWPORT.x), "%s sai pela direita" % node.name)
		assert_lte(rect.end.y, float(VIEWPORT.y), "%s sai por baixo" % node.name)


func test_sprites_are_not_stretched_out_of_proportion() -> void:
	# NinePatch pode esticar: e para isso que serve. TextureRect nao.
	for node in _all_nodes(_root):
		if not (node is TextureRect):
			continue
		assert_eq(node.size, node.texture.get_size(),
			"%s deveria ter o tamanho exato da textura" % node.name)


func test_the_quota_block_is_the_one_with_the_dashed_frame() -> void:
	var blocks := _blocks()
	assert_true(String(blocks[0].texture.resource_path).contains("block_slot_quota"),
		"o bloco de cota usa a moldura tracejada")
	for i in range(1, blocks.size()):
		assert_false(String(blocks[i].texture.resource_path).contains("quota"),
			"o bloco %d nao e de cota" % (i + 1))


func test_the_four_program_blocks_do_not_overlap() -> void:
	var previous_end := -1.0
	for block in _blocks():
		assert_gt(block.get_global_rect().position.x, previous_end,
			"%s encosta no bloco anterior" % block.name)
		previous_end = block.get_global_rect().end.x


# --- a cena mostra o que o autoload contou ---

func test_the_inbox_of_the_night_is_listed() -> void:
	assert_eq(_inbox_rows().size(), 6, "os 6 itens da noite 1")


func test_the_header_shows_night_and_quota() -> void:
	assert_eq(_root.get_node("Header/NightLabel").text, "NOITE 1")
	assert_eq(_root.get_node("Header/QuotaLabel").text, "COTA 0/1")


func test_go_on_air_starts_disabled() -> void:
	assert_true(_root.get_node("Header/GoOnAirButton").disabled,
		"sem programa escalado nao se vai ao ar")


# --- arrastar e soltar ---

func test_blocks_accept_an_inbox_item_and_refuse_anything_else() -> void:
	var block: Control = _blocks()[0]
	assert_true(block._can_drop_data(Vector2.ZERO, {"kind": "inbox_item", "item_id": "x"}))
	assert_false(block._can_drop_data(Vector2.ZERO, {"kind": "outra_coisa"}))
	assert_false(block._can_drop_data(Vector2.ZERO, "um texto qualquer"))


func test_inbox_rows_are_draggable_and_carry_the_item_id() -> void:
	var row: Button = _inbox_rows()[0]
	var data: Variant = row.drag_payload()
	assert_true(data is Dictionary, "a linha deveria entregar dados de arrasto")
	assert_eq(data["kind"], "inbox_item")
	assert_false(String(data["item_id"]).is_empty())


func test_dropping_an_item_schedules_it_in_that_block() -> void:
	_drop_on_block(2, "n01_msg_dona_celia")
	assert_eq(GameState.block_item(2).id, "n01_msg_dona_celia")
	assert_eq(_blocks()[2].get_node("Label").text.substr(0, 3), "A f",
		"o bloco deveria mostrar a manchete do item")


func test_dropping_an_already_scheduled_item_moves_it() -> void:
	_drop_on_block(0, "n01_msg_dona_celia")
	_drop_on_block(3, "n01_msg_dona_celia")
	assert_null(GameState.block_item(0), "o bloco de origem deveria esvaziar")
	assert_eq(GameState.block_item(3).id, "n01_msg_dona_celia")


func test_the_quota_label_reacts_to_the_official_item() -> void:
	_drop_on_block(0, "n01_propaganda_normalidade")
	assert_eq(_root.get_node("Header/QuotaLabel").text, "COTA 1/1")


func test_go_on_air_enables_once_the_program_is_ready() -> void:
	var items := GameState.inbox()
	for i in ProgramRundown.BLOCK_COUNT:
		_drop_on_block(i, items[i].id)
		GameState.set_framing(i, FramingOption.Kind.TRUTH)
	assert_false(_root.get_node("Header/GoOnAirButton").disabled,
		"com os 4 blocos escalados e enquadrados, da para ir ao ar")


# --- cruzar item com caderno pela interface ---

func test_the_notebook_of_the_night_is_listed() -> void:
	assert_eq(_root.get_node("WorkPanel/NotebookView/NotebookList").get_children().size(), 7)


func test_crossing_a_claim_with_the_notebook_reports_a_contradiction() -> void:
	_root._on_inbox_row_pressed("n01_msg_toledo")
	_root._on_claim_row_pressed("c_b_local")
	_root._on_notebook_row_pressed("entry_rua_aurora_evacuada")

	assert_string_contains(_root.get_node("WorkPanel/Feedback").text, "CONTRADI")
	assert_eq(GameState.contradictions_for("n01_msg_toledo"), ["c_b_local"])


func test_crossing_without_marking_a_claim_first_says_so() -> void:
	_root._on_inbox_row_pressed("n01_msg_toledo")
	_root._on_notebook_row_pressed("entry_rua_aurora_evacuada")
	assert_string_contains(_root.get_node("WorkPanel/Feedback").text, "Marque")


func test_opening_an_item_lists_what_there_is_to_check() -> void:
	_root._on_inbox_row_pressed("n01_msg_toledo")
	assert_eq(_root.get_node("WorkPanel/ItemView/ClaimsList").get_children().size(), 2,
		"a denuncia do Toledo tem 2 afirmacoes conferiveis")
	assert_eq(_root.get_node("WorkPanel/ItemView/Headline").text,
		"Vizinho da Aurora estaria entregando nomes")


func test_marking_an_item_as_suspicious_goes_through_the_autoload() -> void:
	_root._on_inbox_row_pressed("n01_msg_toledo")
	_root._on_suspect_pressed()
	assert_true(GameState.is_suspicious("n01_msg_toledo"))
	assert_true(_root.get_node("WorkPanel/ItemView/SuspectButton").button_pressed)


# --- enquadramento pela interface ---

func test_choosing_a_framing_on_a_block() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	_root._on_block_clicked(1)
	_root._on_framing_row_pressed(str(FramingOption.Kind.INFLAME))
	assert_eq(GameState.block_framing(1), FramingOption.Kind.INFLAME)


func test_a_framing_the_item_does_not_allow_is_refused_with_a_message() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	_root._on_block_clicked(1)
	_root._on_framing_row_pressed(str(FramingOption.Kind.IRONY))
	assert_eq(GameState.block_framing(1), ProgramRundown.NO_FRAMING)
	assert_string_contains(_root.get_node("WorkPanel/Feedback").text, "não vale")


func test_clearing_a_block_frees_the_item() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	_root._on_block_clicked(1)
	_root._on_clear_block_pressed()
	assert_null(GameState.block_item(1))


func test_the_work_panel_closes_when_the_program_goes_on_air() -> void:
	var items := GameState.inbox()
	for i in ProgramRundown.BLOCK_COUNT:
		_drop_on_block(i, items[i].id)
		GameState.set_framing(i, FramingOption.Kind.TRUTH)
	_root._on_go_on_air_pressed()

	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_false(_root.get_node("WorkPanel").visible,
		"no ar, o close sai da frente e a mesa aparece")


func _all_nodes(from: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in from.get_children():
		nodes.append(child)
		nodes.append_array(_all_nodes(child))
	return nodes
