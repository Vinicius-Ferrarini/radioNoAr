extends GutTest

## A mesa do estudio. Reescrito no M8B: as garantias sao as mesmas do M8
## (cruzar trecho com caderno funciona pela interface, arrastar escala,
## cota reage), mas agora pelos objetos da mesa em vez do painel de abas
## (ADR 0010).

const SCENE_PATH := "res://scenes/studio_desk.tscn"
const VIEWPORT := Vector2i(320, 180)

## A mesa e a casa: estes nos existem sempre (GAME_DESIGN secao 12).
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
	"Closes/CloseItem",
	"Closes/CloseNotebook",
	"Closes/FramingStrip",
	"Feedback",
	"Blocks/Block1",
	"Blocks/Block2",
	"Blocks/Block3",
	"Blocks/Block4",
	"Lighting",
]

var _root: Control


func before_each() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	_root = scene.instantiate()
	add_child_autofree(_root)
	await get_tree().process_frame


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func after_all() -> void:
	GameState.load_events()
	GameState.reset_run()


func _node(path: String) -> Node:
	return _root.get_node(path)


func _blocks() -> Array[Node]:
	return _node("Blocks").get_children()


func _close_item() -> Control:
	return _node("Closes/CloseItem")


func _avatar_chips() -> Array[Node]:
	return _node("Closes/CloseItem/AvatarRow").get_children()


func _claim_rows() -> Array[Node]:
	return _node("Closes/CloseItem/ClaimsList").get_children()


func _notebook_rows() -> Array[Node]:
	return _node("Closes/CloseNotebook/PageScroll/List").get_children()


func _framing_rows() -> Array[Node]:
	return _node("Closes/FramingStrip/Scroll/List").get_children()


func _drop_on_block(block_index: int, item_id: String) -> void:
	_blocks()[block_index]._drop_data(Vector2.ZERO, {"kind": "inbox_item", "item_id": item_id})


func _press(row: Node) -> void:
	row.row_pressed.emit(row.row_id())


func _all_nodes(from: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in from.get_children():
		nodes.append(child)
		nodes.append_array(_all_nodes(child))
	return nodes


# --- montagem ---

func test_every_promised_node_is_there() -> void:
	for node_path in EXPECTED_NODES:
		assert_not_null(_root.get_node_or_null(node_path), "falta o no '%s'" % node_path)


func test_the_desk_starts_uncovered() -> void:
	assert_false(_close_item().visible, "o close do item comeca fechado")
	assert_false(_node("Closes/CloseNotebook").visible)
	assert_false(_node("Closes/FramingStrip").visible)
	assert_true(_node("Studio/Window").visible, "a mesa aparece desde o inicio")


func test_everything_fits_inside_the_viewport() -> void:
	for node in _all_nodes(_root):
		if not (node is TextureRect or node is NinePatchRect or node is TextureButton):
			continue
		var rect: Rect2 = node.get_global_rect()
		assert_gte(rect.position.x, 0.0, "%s sai pela esquerda" % node.name)
		assert_gte(rect.position.y, 0.0, "%s sai por cima" % node.name)
		assert_lte(rect.end.x, float(VIEWPORT.x), "%s sai pela direita" % node.name)
		assert_lte(rect.end.y, float(VIEWPORT.y), "%s sai por baixo" % node.name)


func test_sprites_are_not_stretched_out_of_proportion() -> void:
	# NinePatch pode esticar: e para isso que serve. TextureRect nao.
	for node in _all_nodes(_root):
		if not (node is TextureRect) or node.texture == null:
			continue
		assert_eq(node.size, node.texture.get_size(),
			"%s deveria ter o tamanho exato da textura" % node.name)


func test_the_quota_block_is_the_one_with_the_dashed_frame() -> void:
	var blocks := _blocks()
	assert_true(String(blocks[0].texture.resource_path).contains("block_slot_quota"))
	for i in range(1, blocks.size()):
		assert_false(String(blocks[i].texture.resource_path).contains("quota"))


func test_the_header_shows_night_and_quota() -> void:
	assert_eq(_node("Header/NightLabel").text, "NOITE 1")
	assert_eq(_node("Header/QuotaLabel").text, "COTA 0/1")
	assert_true(_node("Header/GoOnAirButton").disabled)


# --- o celular ---

func test_opening_the_phone_shows_a_conversation() -> void:
	_root._open_phone()
	assert_true(_close_item().visible, "o celular abre em close")
	assert_eq(_node("Closes/CloseItem/SenderName").text, "Dona Célia",
		"a primeira conversa e a da Dona Celia")
	assert_eq(_node("Closes/CloseItem/SenderHandle").text, "(fixo) 2-4417")
	assert_eq(_node("Closes/CloseItem/ReceivedAt").text, "19:42")


func test_the_phone_lists_only_phone_conversations() -> void:
	_root._open_phone()
	assert_eq(_avatar_chips().size(), 3, "3 mensagens de celular na noite 1")


func test_switching_conversation_by_the_avatar() -> void:
	_root._open_phone()
	_press(_avatar_chips()[1])
	assert_eq(_node("Closes/CloseItem/SenderName").text, "J. Toledo")


func test_avatar_chips_are_draggable_and_carry_the_item() -> void:
	_root._open_phone()
	var payload: Variant = _avatar_chips()[0].drag_payload()
	assert_true(payload is Dictionary, "arrasta-se a pessoa para o bloco")
	assert_eq(payload["item_id"], "n01_msg_dona_celia")


# --- as cartas ---

func test_opening_the_letters_shows_paper_not_phone() -> void:
	_root._open_letters()
	assert_true(_close_item().visible)
	assert_eq(_avatar_chips().size(), 3, "2 cartas + 1 comunicado oficial")
	assert_false(_node("Closes/CloseItem/BubbleFrame").visible,
		"papel nao tem balao de mensagem")
	assert_true(_node("Closes/CloseItem/Mark").visible, "carta tem lacre")


func test_the_official_communique_looks_official() -> void:
	_root._open_item("n01_propaganda_normalidade")
	assert_eq(_node("Closes/CloseItem/SenderName").text, "Ministério das Comunicações")
	assert_true(String(_node("Closes/CloseItem/Mark").texture.resource_path).contains("stamp"),
		"comunicado tem carimbo, nao lacre")


func test_paper_and_phone_do_not_share_a_surface() -> void:
	_root._open_item("n01_msg_dona_celia")
	var phone_surface: String = _node("Closes/CloseItem/Surface").texture.resource_path
	_root._open_item("n01_carta_a_mendes")
	var letter_surface: String = _node("Closes/CloseItem/Surface").texture.resource_path
	assert_ne(phone_surface, letter_surface,
		"celular e carta precisam ser reconheciveis antes de ler")


# --- cruzar com o caderno ---

func test_marking_a_claim_opens_the_notebook() -> void:
	_root._open_item("n01_msg_toledo")
	assert_eq(_claim_rows().size(), 2, "a denuncia do Toledo tem 2 trechos conferiveis")
	_press(_claim_rows()[0])

	assert_true(_node("Closes/CloseNotebook").visible, "marcar um trecho abre o caderno")
	assert_string_contains(_node("Closes/CloseNotebook/Hint").text, "Cruzando")


func test_crossing_with_the_notebook_finds_the_contradiction() -> void:
	_root._open_item("n01_msg_toledo")
	_press(_claim_rows()[0])

	var rows := _notebook_rows()
	assert_eq(rows.size(), 7, "as 7 regras da noite 1")
	for row in rows:
		if row.row_id() == "entry_rua_aurora_evacuada":
			_press(row)

	assert_string_contains(_node("Feedback").text, "CONTRADI")
	assert_eq(GameState.contradictions_for("n01_msg_toledo"), ["c_b_local"])


func test_crossing_the_wrong_line_finds_nothing() -> void:
	_root._open_item("n01_msg_toledo")
	_press(_claim_rows()[0])
	for row in _notebook_rows():
		if row.row_id() == "entry_toque_recolher_centro":
			_press(row)

	assert_string_contains(_node("Feedback").text, "Não tem relação")
	assert_eq(GameState.contradictions_for("n01_msg_toledo").size(), 0)


func test_the_notebook_says_when_nothing_is_marked() -> void:
	_root._open_notebook()
	assert_string_contains(_node("Closes/CloseNotebook/Hint").text, "Marque um trecho")


func test_marking_an_item_as_suspicious_goes_through_the_autoload() -> void:
	_root._open_item("n01_msg_toledo")
	_root._on_suspect_toggled()
	assert_true(GameState.is_suspicious("n01_msg_toledo"))


# --- escalar ---

func test_dropping_an_item_schedules_it_and_shows_who() -> void:
	_drop_on_block(2, "n01_msg_dona_celia")
	assert_eq(GameState.block_item(2).id, "n01_msg_dona_celia")
	assert_string_contains(_blocks()[2].get_node("Label").text, "Célia",
		"o bloco mostra quem vai falar, nao um numero")


func test_dropping_opens_the_framing_strip() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	assert_true(_node("Closes/FramingStrip").visible)
	assert_eq(_framing_rows().size(), 5, "a Dona Celia aceita 5 enquadramentos")


func test_dropping_an_already_scheduled_item_moves_it() -> void:
	_drop_on_block(0, "n01_msg_dona_celia")
	_drop_on_block(3, "n01_msg_dona_celia")
	assert_null(GameState.block_item(0))
	assert_eq(GameState.block_item(3).id, "n01_msg_dona_celia")


func test_the_quota_label_reacts_to_the_official_item() -> void:
	_drop_on_block(0, "n01_propaganda_normalidade")
	assert_eq(_node("Header/QuotaLabel").text, "COTA 1/1")


func test_choosing_a_framing_from_the_strip() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	for row in _framing_rows():
		if int(row.row_id()) == FramingOption.Kind.INFLAME:
			_press(row)
	assert_eq(GameState.block_framing(1), FramingOption.Kind.INFLAME)
	assert_string_contains(_node("Feedback").text, "Inflamar")


func test_only_the_official_item_offers_irony() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	var kinds: Array[int] = []
	for row in _framing_rows():
		kinds.append(int(row.row_id()))
	assert_false(kinds.has(FramingOption.Kind.IRONY), "ironia nao vale para mensagem de gente")

	_drop_on_block(0, "n01_propaganda_normalidade")
	kinds.clear()
	for row in _framing_rows():
		kinds.append(int(row.row_id()))
	assert_true(kinds.has(FramingOption.Kind.IRONY), "o comunicado pode ser ironizado")


func test_clearing_a_block_frees_the_item() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	_root._on_clear_block()
	assert_null(GameState.block_item(1))


func test_the_badge_counts_what_is_still_unscheduled() -> void:
	assert_eq(_node("Phone/PhoneBadge").text, "3", "3 mensagens esperando")
	_drop_on_block(0, "n01_msg_dona_celia")
	assert_eq(_node("Phone/PhoneBadge").text, "2")


# --- ir ao ar ---

func test_going_on_air_needs_the_whole_program() -> void:
	_root._on_go_on_air_pressed()
	assert_eq(GameState.current_phase(), NightCycle.Phase.TRIAGE)
	assert_string_contains(_node("Feedback").text, "quatro blocos")


func test_going_on_air_clears_the_desk_objects() -> void:
	var items := GameState.inbox()
	for i in ProgramRundown.BLOCK_COUNT:
		_drop_on_block(i, items[i].id)
		GameState.set_framing(i, FramingOption.Kind.TRUTH)
	_root._on_go_on_air_pressed()

	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_false(_node("Phone").visible, "no ar, o celular sai da mesa")
	assert_false(_close_item().visible)
	assert_string_contains(_node("Studio/Teleprompter/ScriptText").text, "NO AR")
