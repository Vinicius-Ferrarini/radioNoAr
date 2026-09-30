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
	"EnterAirButton",
	"RundownPaper",
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
	_root.campaign_directory = ContentLibrary.NIGHTS_DIR
	add_child_autofree(_root)
	await get_tree().process_frame


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func after_all() -> void:
	GameState.start_run(0, ContentLibrary.NIGHTS_DIR)


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
#
# Desde o ADR 0013 o celular e um aparelho em pe com lista de conversas, e
# nao o close de papel. Os testes abaixo cobrem a mesma coisa que cobriam
# — o que o celular lista, quem e a conversa, e arrastar a pessoa para o
# bloco — na superficie nova.

func _phone_rows() -> Array[Node]:
	return _node("Closes/ClosePhone/ListScroll/List").get_children()


func _phone_title() -> String:
	return _node("Closes/ClosePhone/Title").text


func test_opening_the_phone_shows_the_conversation_list() -> void:
	_root._open_phone()
	assert_true(_node("Closes/ClosePhone").visible, "o celular abre como aparelho")
	assert_false(_close_item().visible, "papel nao entra aqui")
	assert_eq(_phone_title(), "MENSAGENS")
	assert_string_contains(_phone_rows()[0].text, "Dona Célia",
		"a primeira conversa e a da Dona Celia")


## A hora da ultima fala e a data de hoje ficam na tela, como em qualquer
## aparelho.
func test_the_phone_shows_the_date_and_the_time_of_the_last_message() -> void:
	_root._open_phone()
	assert_eq(_node("Closes/ClosePhone/Today").text, GameCalendar.date_of(1))
	assert_string_contains(_phone_rows()[0].text, "19:00",
		"a lista mostra a hora que o relogio marcou na ultima fala")


func test_the_phone_lists_only_phone_conversations() -> void:
	_root._open_phone()
	assert_eq(_phone_rows().size(), 3, "3 mensagens de celular na noite 1")


func test_entering_a_conversation_from_the_list() -> void:
	_root._open_phone()
	_press(_phone_rows()[1])
	assert_eq(_phone_title(), "J. Toledo")
	assert_true(_node("Closes/ClosePhone/ChatScroll").visible)


func test_phone_rows_are_draggable_and_carry_the_item() -> void:
	_root._open_phone()
	var payload: Variant = _phone_rows()[0].drag_payload()
	assert_true(payload is Dictionary, "arrasta-se a conversa para o bloco")
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


## Antes era a mesma cena com outra textura; agora sao dois objetos
## diferentes, o que e ainda mais reconhecivel antes de ler.
func test_paper_and_phone_do_not_share_a_surface() -> void:
	_root._open_item("n01_msg_dona_celia")
	assert_true(_node("Closes/ClosePhone").visible)
	assert_false(_close_item().visible)

	_root._open_item("n01_carta_a_mendes")
	assert_true(_close_item().visible)
	assert_false(_node("Closes/ClosePhone").visible)


# --- cruzar com o caderno ---

func _phone_claim_rows() -> Array[Node]:
	return _node("Closes/ClosePhone/Claims").get_children()


func test_marking_a_claim_opens_the_notebook() -> void:
	_root._open_item("n01_msg_toledo")
	assert_eq(_phone_claim_rows().size(), 2,
		"a denuncia do Toledo tem 2 trechos conferiveis, agora no aparelho")
	_press(_phone_claim_rows()[0])

	assert_true(_node("Closes/CloseNotebook").visible, "marcar um trecho abre o caderno")
	assert_string_contains(_node("Closes/CloseNotebook/Hint").text, "Cruzando")


func test_crossing_with_the_notebook_finds_the_contradiction() -> void:
	_root._open_item("n01_msg_toledo")
	_press(_phone_claim_rows()[0])

	var rows := _notebook_rows()
	assert_eq(rows.size(), 7, "as 7 regras da noite 1")
	for row in rows:
		if row.row_id() == "entry_rua_aurora_evacuada":
			_press(row)

	assert_string_contains(_node("Feedback").text, "CONTRADI")
	assert_eq(GameState.contradictions_for("n01_msg_toledo"), ["c_b_local"])


func test_crossing_the_wrong_line_finds_nothing() -> void:
	_root._open_item("n01_msg_toledo")
	_press(_phone_claim_rows()[0])
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
	_drop_on_block(1, "n01_carta_a_mendes")
	assert_true(_node("Closes/FramingStrip").visible)
	assert_eq(_framing_rows().size(), 4, "a carta ao Mendes aceita 4 enquadramentos")


## O outro lado da mesma regra: mensagem de celular nao abre regua nenhuma,
## abre a conversa (ADR 0013).
func test_dropping_a_phone_message_opens_the_conversation() -> void:
	_drop_on_block(1, "n01_msg_dona_celia")
	assert_false(_node("Closes/FramingStrip").visible, "a regua nao entra no celular")
	assert_true(_node("Closes/ClosePhone").visible, "quem decide agora e a conversa")


func test_dropping_an_already_scheduled_item_moves_it() -> void:
	_drop_on_block(0, "n01_msg_dona_celia")
	_drop_on_block(3, "n01_msg_dona_celia")
	assert_null(GameState.block_item(0))
	assert_eq(GameState.block_item(3).id, "n01_msg_dona_celia")


func test_the_quota_label_reacts_to_the_official_item() -> void:
	_drop_on_block(0, "n01_propaganda_normalidade")
	assert_eq(_node("Header/QuotaLabel").text, "COTA 1/1")


## Carta e nao mensagem: desde o ADR 0013 o celular decide na conversa, e
## a regua e a superficie do papel. O que este teste cobre — a regua lista
## os enquadramentos do item e escolher um fixa o bloco — segue igual.
func test_choosing_a_framing_from_the_strip() -> void:
	_drop_on_block(1, "n01_carta_envelope_azul")
	for row in _framing_rows():
		if int(row.row_id()) == FramingOption.Kind.INFLAME:
			_press(row)
	assert_eq(GameState.block_framing(1), FramingOption.Kind.INFLAME)
	assert_string_contains(_node("Feedback").text, "Inflamar")


func test_only_the_official_item_offers_irony() -> void:
	_drop_on_block(1, "n01_carta_a_mendes")
	var kinds: Array[int] = []
	for row in _framing_rows():
		kinds.append(int(row.row_id()))
	assert_false(kinds.has(FramingOption.Kind.IRONY), "ironia nao vale para carta de gente")

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

func test_going_on_air_needs_at_least_one_decision() -> void:
	_root._on_go_on_air_pressed()
	assert_eq(GameState.current_phase(), NightCycle.Phase.TRIAGE)
	assert_string_contains(_node("Feedback").text, "roteiro ainda está vazio")


## ADR 0014 substitui a grade fixa: decidir no documento atualiza a folha
## e uma única decisão completa já permite entrar no ar.
func test_deciding_on_a_paper_updates_the_automatic_rundown() -> void:
	assert_false(_node("Blocks").visible, "a grade de quatro blocos saiu da interface")
	assert_true(_node("RundownPaper").visible)
	assert_string_contains(_node("RundownPaper/Paper/Warning").text, "Responda")

	_root._open_item("n01_carta_envelope_azul")
	var choices := _node("Closes/CloseItem/Decisions").get_children()
	assert_gt(choices.size(), 0, "o papel oferece a decisão no próprio documento")
	choices[0].pressed.emit()

	assert_true(GameState.is_rundown_ready())
	assert_eq(GameState.block_of_item("n01_carta_envelope_azul"), 0)
	assert_gt(GameState.rundown_estimated_seconds(), 0.0)
	assert_string_contains(_node("RundownPaper/Paper/Total").text, "0:")
	assert_string_contains(_node("Feedback").text, "entrou no roteiro")


## --- atmosfera (ADR 0012) ---

## O estudio tem leito continuo. Se o loop se perder numa regeracao de
## audio, o som toca uma vez e a mesa emudece sem ninguem notar.
func test_the_studio_keeps_a_continuous_bed_that_loops() -> void:
	var ambience: AudioStreamPlayer = _node("Ambience")
	var noise: AudioStreamPlayer = _node("Static")
	assert_not_null(ambience.stream, "o zumbido do estudio precisa de stream")
	assert_not_null(noise.stream, "a estatica precisa de stream")
	assert_eq(ambience.stream.loop_mode, AudioStreamWAV.LOOP_FORWARD,
		"leito sem loop toca uma vez e o estudio emudece")
	assert_eq(noise.stream.loop_mode, AudioStreamWAV.LOOP_FORWARD,
		"estatica sem loop para no meio do ar morto")


## O ar morto tem que doer no ouvido, nao so no texto do rodape.
func test_dead_air_is_audible_and_darkens_the_sign() -> void:
	_schedule_whole_program()
	_root._on_go_on_air_pressed()
	_root._on_mic_down()
	for i in 30:
		_root._breathe(0.5)
	var static_on_air: float = _node("Static").volume_db
	var sign_on_air: float = _node("Studio/OnAirSign").modulate.a

	_root._on_mic_up()
	GameState._process(0.1)
	for i in 30:
		_root._breathe(0.5)
	assert_gt(_node("Static").volume_db, static_on_air,
		"no ar morto a estatica sobe")
	assert_lt(_node("Studio/OnAirSign").modulate.a, sign_on_air,
		"e o letreiro apaga junto com a voz")


## Fora do ar a mesa nao fica congelada: a lampada oscila.
func test_the_desk_lamp_never_sits_still() -> void:
	var first: float = _node("Studio/DeskLamp").modulate.a
	_root._clock += 0.7
	_root._breathe(0.016)
	assert_ne(_node("Studio/DeskLamp").modulate.a, first,
		"a luz da mesa respira")


## O botao dedicado nunca fica desabilitado e nunca fica calado: em
## qualquer estado ele responde, e antes do ar ele abre o que falta.
func test_the_enter_air_button_always_answers() -> void:
	var button: Button = _node("EnterAirButton")
	assert_false(button.disabled, "este botao nunca fica desabilitado")

	# Mesa vazia: explica a decisão e abre o celular para começar.
	button.pressed.emit()
	assert_eq(GameState.current_phase(), NightCycle.Phase.TRIAGE)
	assert_string_contains(_node("Feedback").text, "Responda no celular")
	assert_true(_node("Closes/ClosePhone").visible, "abre o celular, onde estao as pessoas")
	assert_false(button.disabled)

	# Uma decisão completa no papel já forma um roteiro válido.
	_root._open_item("n01_carta_envelope_azul")
	_node("Closes/CloseItem/Decisions").get_child(0).pressed.emit()
	button.pressed.emit()
	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_false(button.disabled, "no ar ele continua clicavel")

	# Já no ar: continua respondendo, sem quebrar a transmissao.
	button.pressed.emit()
	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_string_contains(_node("Feedback").text, "já está no ar")


## Arrastar para um bloco ocupado nao pode ser silencioso.
func test_a_refused_drop_explains_itself() -> void:
	_drop_on_block(0, "n01_msg_dona_celia")
	_drop_on_block(0, "n01_msg_toledo")
	assert_string_contains(_node("Feedback").text, "já tem alguém")
	assert_eq(GameState.block_item(0).id, "n01_msg_dona_celia")


func test_going_on_air_clears_the_desk_objects() -> void:
	_schedule_whole_program()
	_root._on_go_on_air_pressed()

	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_true(_node("Phone").visible, "no ar, as ferramentas continuam acessíveis")
	assert_false(_close_item().visible)
	assert_true(_node("Studio/BlockLabel").visible)
	assert_string_contains(_node("Studio/BlockLabel").text, "ROTEIRO 1 DE 4")
	assert_false(_node("RundownPaper").visible, "a folha libera espaço para o console ao vivo")


func test_the_teleprompter_shows_the_script_of_the_block() -> void:
	_schedule_whole_program()
	_root._on_go_on_air_pressed()
	_root._refresh_live()

	var prompter: String = _node("Studio/Teleprompter/ScriptText").text
	assert_string_contains(prompter, "Célia", "a primeira linha do roteiro da Dona Celia")
	assert_string_contains(prompter, "[b]", "a linha de agora vem em destaque")


func test_the_microphone_is_only_usable_on_air() -> void:
	assert_true(_node("Studio/Microphone").disabled, "antes do ar, o microfone nao responde")
	_schedule_whole_program()
	_root._on_go_on_air_pressed()
	assert_false(_node("Studio/Microphone").disabled)


func test_holding_the_microphone_moves_the_script() -> void:
	_schedule_whole_program()
	_root._on_go_on_air_pressed()

	_root._on_mic_down()
	for i in 60:
		GameState._process(1.0 / 60.0)
	_root._refresh_live()

	assert_gt(_node("Studio/Teleprompter/LineProgress").value, 0.0)


func test_letting_go_warns_about_dead_air() -> void:
	_schedule_whole_program()
	_root._on_go_on_air_pressed()
	_root._on_mic_down()
	_root._on_mic_up()
	GameState._process(1.0 / 60.0)

	assert_string_contains(_node("Feedback").text, "AR MORTO")


func test_a_forbidden_word_is_a_link_with_no_highlight() -> void:
	# O roteiro da verdade sobre a fila esconde a palavra "greve" na
	# segunda linha. Ela vira link clicavel, sem nada que a destaque.
	GameState.place_item("n01_msg_dona_celia", 0)
	GameState.set_framing(0, FramingOption.Kind.TRUTH)
	for i in range(1, ProgramRundown.BLOCK_COUNT):
		GameState.place_item(GameState.inbox()[i].id, i)
		GameState.set_framing(i, FramingOption.Kind.DISCARD)
	_root._on_go_on_air_pressed()

	assert_string_contains(_root._with_forbidden_links(1), "[url=0]greve[/url]")

	_root._on_prompter_meta_clicked("0")
	assert_string_contains(GameState.live_line_text(1), "paralisação voluntária")
	assert_string_contains(_node("Feedback").text, "Trocado")


func test_the_improv_opens_with_its_own_clock() -> void:
	_schedule_whole_program()
	_root._on_go_on_air_pressed()
	_root._on_mic_down()

	var steps := 0
	while _node("Closes/ImprovStrip").visible == false and steps < 3000:
		GameState._process(1.0 / 60.0)
		steps += 1

	assert_lt(steps, 3000, "algum bloco da noite 1 tem improviso")
	assert_gt(_node("Closes/ImprovStrip/Scroll/List").get_children().size(), 1,
		"improviso oferece mais de uma saida")
	assert_false(_node("Closes/ImprovStrip/Prompt").text.is_empty())


func _schedule_whole_program() -> void:
	var items := GameState.inbox()
	for i in ProgramRundown.BLOCK_COUNT:
		_drop_on_block(i, items[i].id)
		GameState.set_framing(i, FramingOption.Kind.TRUTH)
