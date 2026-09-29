extends GutTest

var desk: Control


func before_each() -> void:
	desk = load("res://scenes/studio_desk.tscn").instantiate()
	add_child_autofree(desk)
	GameState.set_process(false)
	await get_tree().process_frame


func after_each() -> void:
	GameState.set_process(true)


func _schedule() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	var items := GameState.inbox()
	for i in 4:
		desk._on_item_dropped(items[i].id, i)
		desk._on_framing_chosen(0)
	desk.get_node("Header/GoOnAirButton").pressed.emit()


func test_initial_briefing_and_framing_explain_the_work() -> void:
	assert_true(desk.get_node("Briefing").visible)
	assert_string_contains(desk.get_node("Briefing/Body").text, "aniversário")
	assert_eq(desk.get_node("Header/QuotaLabel").text, "PROGRAMA LIVRE")
	desk.get_node("Briefing/Start").pressed.emit()
	desk._on_item_dropped("p1_placar", 0)
	var rows: Array = desk.get_node("Closes/FramingStrip/Scroll/List").get_children()
	var truth: Button = rows[1]
	assert_true(truth.disabled)
	assert_string_contains(truth.text, "caderno")
	GameState.link_claim("p1_placar", "p1_placar_claim", "p_placar")
	desk._on_block_clicked(0)
	rows = desk.get_node("Closes/FramingStrip/Scroll/List").get_children()
	assert_false(rows[1].disabled)


## --- a conversa é a decisão (ADR 0013) ---

func _thread_bubbles() -> Array:
	return desk.get_node("Closes/CloseItem/BubbleFrame/BodyScroll/Thread").get_children()


func _reply_rows() -> Array:
	return desk.get_node("Closes/CloseItem/Replies").get_children()


func _wait_for_her_to_finish() -> void:
	for i in 100:
		GameState._process(0.1)
	desk._refresh_item()


## A rajada chega aos poucos e a régua não aparece: o celular é o lugar
## da decisão agora.
func test_the_conversation_arrives_one_message_at_a_time() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_celia")
	assert_eq(_thread_bubbles().size(), 1, "ela ainda está digitando o resto")
	assert_eq(_reply_rows().size(), 0, "não se responde no meio da frase")
	assert_false(desk.get_node("Closes/CloseItem/BubbleFrame/BodyScroll/Body").visible,
		"o parágrafo sai de cena quando há conversa")

	_wait_for_her_to_finish()
	assert_eq(_thread_bubbles().size(), 5)
	assert_eq(_reply_rows().size(), 3, "as três respostas ficam fixas embaixo")
	assert_false(desk.get_node("Closes/FramingStrip").visible, "a régua não entra aqui")


## O que você responde entra na thread e decide o enquadramento do bloco.
func test_the_reply_becomes_your_bubble_and_the_block_inherits_it() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_celia")
	_wait_for_her_to_finish()

	var rows := _reply_rows()
	rows[0].row_pressed.emit(rows[0].row_id())
	desk._refresh_item()

	var mine := _thread_bubbles().filter(func(b: Node) -> bool: return b.get_node("Text").text == "Dou os parabéns no ar.")
	assert_eq(mine.size(), 1, "a sua fala entra na thread")
	assert_eq(_reply_rows().size(), 0, "respondido, não há mais o que escolher")

	desk._on_item_dropped("p1_celia", 0)
	assert_eq(GameState.block_framing(0), FramingOption.Kind.AS_RECEIVED,
		"o bloco herda o que você disse a ela")
	assert_string_contains(desk.get_node("Blocks/Block1/Label").text, "Dar os parabéns")


## Enquanto não há resposta, a mesa manda para o celular, não para a régua.
func test_an_undecided_conversation_points_to_the_phone() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._on_item_dropped("p1_celia", 0)
	assert_string_contains(desk.get_node("Feedback").text, "responda a conversa",
		"o rodapé manda conversar, não escolher enquadramento")
	assert_true(desk.get_node("Header/GoOnAirButton").disabled)


func test_visible_controls_cut_call_preserve_reaction_and_reach_morning() -> void:
	_schedule()
	assert_true(desk.get_node("Notebook").visible)
	desk.get_node("Studio/Microphone").pressed.emit()
	assert_true(GameState.microphone_open())
	var steps := 0
	while not GameState.live_console().get("pending", false) and steps < 1000:
		GameState._process(0.1)
		steps += 1
	assert_lt(steps, 1000)
	desk._refresh_live()
	assert_false(desk.get_node("CallPanel/Cut").disabled)
	assert_string_contains(desk.get_node("CallPanel/Status").text, "PRÉVIA")
	desk.get_node("CallPanel/Cut").pressed.emit()
	assert_string_contains(desk.get_node("CallPanel/Status").text, "CORTADO")
	steps = 0
	while not GameState.is_live_done() and steps < 2000:
		GameState._process(0.1)
		steps += 1
	assert_lt(steps, 2000)
	desk._refresh_live()
	assert_string_contains(desk.get_node("CallPanel/Transcript").text, "Essa eu te devo")
	assert_eq(desk.get_node("Header/GoOnAirButton").text, "MANHÃ")
	desk.get_node("Header/GoOnAirButton").pressed.emit()
	assert_true(desk.get_node("Closes/CloseMorning").visible)
	desk.get_node("Closes/CloseMorning/ContinueButton").pressed.emit()
	assert_eq(GameState.current_night(), 2)
	assert_true(desk.get_node("Briefing").visible)


func test_space_is_a_toggle_not_a_hold() -> void:
	_schedule()
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	key.pressed = true
	desk._input(key)
	assert_true(GameState.microphone_open())
	key.pressed = false
	desk._input(key)
	assert_true(GameState.microphone_open(), "soltar não fecha o microfone")
	key.pressed = true
	desk._input(key)
	assert_false(GameState.microphone_open())
