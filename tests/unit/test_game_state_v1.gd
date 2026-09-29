extends GutTest

## O autoload v1: a ponte entre a logica e a cena. Nao decide nada,
## delega para RunState/NightCycle e traduz em sinais.


func before_each() -> void:
	GameState.start_run(1234)


func after_all() -> void:
	# Deixa o autoload como as cenas e os testes da v0 esperam.
	GameState.load_events()
	GameState.reset_run()


func _fill_program(kind := FramingOption.Kind.TRUTH) -> void:
	var items := GameState.inbox()
	for i in ProgramRundown.BLOCK_COUNT:
		GameState.place_item(items[i].id, i)
		GameState.set_framing(i, kind)


# --- comeco de campanha ---

func test_start_run_opens_night_one_in_triage() -> void:
	assert_eq(GameState.current_night(), 1)
	assert_eq(GameState.current_phase(), NightCycle.Phase.TRIAGE)
	assert_eq(GameState.inbox().size(), 6, "a inbox da noite 1 tem 6 itens")


func test_start_run_announces_the_night() -> void:
	watch_signals(GameState)
	GameState.start_run(1234)
	assert_signal_emitted(GameState, "night_started")
	assert_signal_emitted(GameState, "inbox_ready")
	assert_signal_emitted(GameState, "notebook_updated")
	assert_signal_emitted(GameState, "quota_changed")
	assert_signal_emitted_with_parameters(GameState, "night_started", [1, 1])


func test_notebook_starts_with_the_entries_of_the_night() -> void:
	assert_eq(GameState.notebook_entries().size(), 7)


func test_item_by_id_finds_and_misses_cleanly() -> void:
	assert_not_null(GameState.item_by_id("n01_msg_toledo"))
	assert_null(GameState.item_by_id("nao_existe"))


func test_same_seed_gives_the_same_run() -> void:
	GameState.start_run(99)
	var first: int = GameState.rng_sample()
	GameState.start_run(99)
	assert_eq(GameState.rng_sample(), first, "mesma seed, mesma campanha")


# --- triagem: cruzar item com caderno ---

func test_link_claim_reports_a_contradiction() -> void:
	watch_signals(GameState)
	var result := GameState.link_claim("n01_msg_toledo", "c_b_local", "entry_rua_aurora_evacuada")

	assert_eq(result, Validator.Result.CONTRADICTION)
	assert_signal_emitted(GameState, "link_evaluated")
	assert_eq(GameState.contradictions_for("n01_msg_toledo"), ["c_b_local"])


func test_link_claim_with_unrelated_entry_finds_nothing() -> void:
	var result := GameState.link_claim("n01_msg_toledo", "c_b_local", "entry_toque_recolher_centro")
	assert_eq(result, Validator.Result.UNRELATED)
	assert_eq(GameState.contradictions_for("n01_msg_toledo").size(), 0)


func test_link_claim_on_an_unknown_item_is_harmless() -> void:
	assert_eq(GameState.link_claim("nao_existe", "c", "e"), Validator.Result.UNRELATED)


func test_toggle_suspicion_flips_and_announces() -> void:
	watch_signals(GameState)
	assert_false(GameState.is_suspicious("n01_msg_toledo"))

	GameState.toggle_suspicion("n01_msg_toledo")
	assert_true(GameState.is_suspicious("n01_msg_toledo"))
	assert_signal_emitted_with_parameters(GameState, "suspicion_changed", ["n01_msg_toledo", true])

	GameState.toggle_suspicion("n01_msg_toledo")
	assert_false(GameState.is_suspicious("n01_msg_toledo"))


# --- escalacao ---

func test_place_item_fills_a_block_and_announces() -> void:
	GameState.advance_phase()
	watch_signals(GameState)

	assert_eq(GameState.place_item("n01_msg_dona_celia", 0), ProgramRundown.PlaceResult.OK)
	assert_signal_emitted(GameState, "rundown_changed")
	assert_eq(GameState.block_item(0).id, "n01_msg_dona_celia")


func test_place_item_refuses_an_occupied_block() -> void:
	GameState.place_item("n01_msg_dona_celia", 0)
	assert_eq(GameState.place_item("n01_msg_toledo", 0), ProgramRundown.PlaceResult.BLOCK_TAKEN)


func test_place_item_with_unknown_id_is_invalid() -> void:
	assert_eq(GameState.place_item("nao_existe", 0), ProgramRundown.PlaceResult.INVALID_BLOCK)


func test_move_block_swaps_and_announces() -> void:
	GameState.place_item("n01_msg_dona_celia", 0)
	GameState.place_item("n01_msg_toledo", 1)
	watch_signals(GameState)

	assert_eq(GameState.move_block(0, 1), ProgramRundown.PlaceResult.OK)
	assert_eq(GameState.block_item(0).id, "n01_msg_toledo")
	assert_signal_emitted(GameState, "rundown_changed")


func test_clear_block_frees_the_item() -> void:
	GameState.place_item("n01_msg_dona_celia", 0)
	GameState.clear_block(0)
	assert_null(GameState.block_item(0))
	assert_eq(GameState.place_item("n01_msg_dona_celia", 2), ProgramRundown.PlaceResult.OK)


func test_set_framing_refuses_what_the_item_does_not_allow() -> void:
	GameState.place_item("n01_msg_dona_celia", 0)
	assert_eq(GameState.set_framing(0, FramingOption.Kind.IRONY),
		ProgramRundown.PlaceResult.FRAMING_NOT_ALLOWED)
	assert_eq(GameState.block_framing(0), ProgramRundown.NO_FRAMING)


func test_irony_is_allowed_on_the_official_communique() -> void:
	GameState.place_item("n01_propaganda_normalidade", 0)
	assert_eq(GameState.set_framing(0, FramingOption.Kind.IRONY), ProgramRundown.PlaceResult.OK)


# --- cota ---

func test_quota_changed_reports_required_and_filled() -> void:
	watch_signals(GameState)
	GameState.place_item("n01_propaganda_normalidade", 0)
	assert_signal_emitted_with_parameters(GameState, "quota_changed", [1, 1])


func test_discarding_the_official_item_empties_the_quota() -> void:
	GameState.place_item("n01_propaganda_normalidade", 0)
	GameState.set_framing(0, FramingOption.Kind.DISCARD)
	assert_eq(GameState.quota_filled(), 0, "descartar a cota nao cumpre a cota")
	assert_eq(GameState.quota_required(), 1)


# --- fases ---

func test_cannot_go_on_air_with_an_incomplete_program() -> void:
	GameState.advance_phase()
	assert_eq(GameState.current_phase(), NightCycle.Phase.RUNDOWN)
	assert_false(GameState.is_rundown_ready())
	assert_false(GameState.advance_phase(), "programa incompleto nao vai ao ar")
	assert_eq(GameState.current_phase(), NightCycle.Phase.RUNDOWN)


func test_the_night_advances_once_the_program_is_ready() -> void:
	GameState.advance_phase()
	_fill_program()
	watch_signals(GameState)

	assert_true(GameState.is_rundown_ready())
	assert_true(GameState.advance_phase())
	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_signal_emitted(GameState, "phase_changed")


func test_morning_is_announced_with_a_report() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()
	watch_signals(GameState)

	assert_true(GameState.advance_phase())
	assert_eq(GameState.current_phase(), NightCycle.Phase.MORNING)
	assert_signal_emitted(GameState, "morning_ready")
	assert_true(GameState.morning_report().has("headlines"))


# --- o invariante de vazamento ---

func test_meter_changed_only_fires_for_visible_meters() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()
	watch_signals(GameState)
	GameState.advance_phase()

	var emitted: Array[String] = []
	for i in get_signal_emit_count(GameState, "meter_changed"):
		emitted.append(get_signal_parameters(GameState, "meter_changed", i)[0])

	assert_true(emitted.has(Meters.AUDIENCE_TRUST), "a confianca da audiencia e visivel")
	for meter_id in emitted:
		assert_false(Meters.is_hidden(meter_id),
			"medidor escondido nao pode chegar na UI: %s" % meter_id)


func test_visible_meters_never_includes_a_hidden_one() -> void:
	var visible := GameState.visible_meters()
	assert_gt(visible.size(), 0)
	for meter_id in visible:
		assert_false(Meters.is_hidden(meter_id), "%s deveria estar escondido" % meter_id)
	assert_eq(visible.size(), 3, "audiencia, temperatura das ruas e alinhamento")


# --- a v0 continua de pe ate o M10 (ADR 0003) ---

func test_the_v0_api_still_works() -> void:
	GameState.load_events()
	GameState.reset_run()
	assert_not_null(GameState.get_current_event(), "o loop v0 continua jogavel ate o M10")
	assert_eq(GameState.get_power(), 50)
