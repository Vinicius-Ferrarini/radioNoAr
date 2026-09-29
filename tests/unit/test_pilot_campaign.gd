extends GutTest


func before_each() -> void:
	GameState.start_run(42)


func _prepare() -> void:
	var items := GameState.inbox()
	assert_gte(items.size(), 4)
	for i in 4:
		assert_eq(GameState.place_item(items[i].id, i), ProgramRundown.PlaceResult.OK)
		assert_eq(GameState.set_framing(i, FramingOption.Kind.AS_RECEIVED), ProgramRundown.PlaceResult.OK)
	GameState.advance_phase()
	assert_true(GameState.advance_phase())


func _perform(cut: bool, break_kind := "") -> Dictionary:
	_prepare()
	var took_break := false
	var cut_seen := false
	var steps := 0
	GameState.set_mic_held(true)
	while not GameState.is_live_done() and steps < 2000:
		GameState._process(0.1)
		var console := GameState.live_console()
		if console.get("pending", false):
			if not took_break and not break_kind.is_empty():
				assert_true(GameState.start_break(break_kind))
				took_break = true
			if cut:
				assert_true(GameState.cut_call())
				cut_seen = true
		steps += 1
	assert_lt(steps, 2000, "a transmissão termina sem travar")
	if cut:
		assert_true(cut_seen, "ligação foi acionada no fluxo real")
	assert_true(GameState.advance_phase())
	return GameState.morning_report()


func test_pilot_starts_as_a_neighborhood_radio_with_no_quota() -> void:
	assert_eq(GameState.quota_required(), 0)
	assert_eq(GameState.night_title(), "A nossa frequência")
	assert_not_null(GameState.item_by_id("p1_chave"))
	assert_false(GameState.start_next_night(), "não se pode pular transmissão")


func test_evidence_gate_is_enforced_through_autoload() -> void:
	GameState.place_item("p1_placar", 0)
	assert_eq(GameState.set_framing(0, FramingOption.Kind.TRUTH), ProgramRundown.PlaceResult.FRAMING_NOT_ALLOWED)
	GameState.link_claim("p1_placar", "p1_placar_claim", "p_placar")
	assert_eq(GameState.set_framing(0, FramingOption.Kind.TRUTH), ProgramRundown.PlaceResult.OK)


func test_three_nights_airing_rui_changes_next_inbox_and_ends_cleanly() -> void:
	_perform(false, "music")
	assert_true(GameState.station_mementos()["record"])
	assert_true(GameState.start_next_night())
	assert_string_contains(GameState.opening_message(), "disco")
	var report := _perform(false)
	assert_string_contains(str(report["headlines"]), "MOTORISTAS OUVEM RUI")
	assert_true(GameState.start_next_night())
	assert_not_null(GameState.item_by_id("p3_rui_public"))
	assert_null(GameState.item_by_id("p3_rui_private"))
	assert_true(GameState.station_mementos()["bridge"])
	_perform(false)
	assert_false(GameState.has_next_night())
	assert_false(GameState.start_next_night())
	GameState.restart_run()
	assert_eq(GameState.current_night(), 1)
	assert_false(GameState.station_mementos()["bridge"])


func test_cutting_rui_protects_source_but_costs_public_warning() -> void:
	_perform(true, "ad")
	assert_eq(GameState.station_money(), 38)
	assert_true(GameState.station_mementos()["sponsor"])
	GameState.start_next_night()
	var report := _perform(true)
	assert_string_contains(str(report["headlines"]), "TRÂNSITO CONTINUA PARADO")
	GameState.start_next_night()
	assert_not_null(GameState.item_by_id("p3_rui_private"))
	assert_null(GameState.item_by_id("p3_rui_public"))
	assert_string_contains(GameState.opening_message(), "protegido")
	_perform(true)
	assert_false(GameState.has_next_night())


func test_only_one_reserve_per_night_and_program_cannot_change_live() -> void:
	_prepare()
	GameState.set_mic_held(true)
	assert_true(GameState.start_break("ad"))
	assert_false(GameState.start_break("music"))
	for i in 100:
		GameState._process(0.1)
	assert_false(GameState.start_break("music"))
	assert_ne(GameState.set_framing(0, FramingOption.Kind.DISCARD), ProgramRundown.PlaceResult.OK)
	GameState.clear_block(0)
	assert_not_null(GameState.block_item(0))


func test_all_pilot_references_and_conditional_inboxes_are_valid() -> void:
	for number in range(1, 4):
		var night := ContentLibrary.night(number, ContentLibrary.PILOT_DIR)
		assert_not_null(night)
		assert_gt(night.calls.size(), 0, "noite sem ligação nenhuma")
		for call in night.calls:
			assert_not_null(call)
			for id in call.aired_consequence_ids + call.cut_consequence_ids:
				assert_not_null(ContentLibrary.consequence(id), id)
		for item in night.inbox:
			var sender := ContentLibrary.sender(item.sender_id)
			assert_not_null(sender, item.sender_id)
			assert_true(ResourceLoader.exists("res://assets/sprites/" + sender.avatar + ".png"))
			for framing in item.framings:
				if framing.kind != FramingOption.Kind.DISCARD:
					assert_not_null(ContentLibrary.broadcast_script(framing.script_id), framing.script_id)
				for id in framing.consequence_ids:
					assert_not_null(ContentLibrary.consequence(id), id)


func test_same_choices_reproduce_the_same_report() -> void:
	var first := _perform(false, "music")
	GameState.start_run(42)
	assert_eq(_perform(false, "music"), first)
