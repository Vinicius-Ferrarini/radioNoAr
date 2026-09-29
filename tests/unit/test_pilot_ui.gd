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
