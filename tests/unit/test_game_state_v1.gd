extends GutTest

## O autoload v1: a ponte entre a logica e a cena. Nao decide nada,
## delega para RunState/NightCycle e traduz em sinais.


func before_each() -> void:
	GameState.start_run(1234)


func after_all() -> void:
	# Deixa o autoload numa campanha limpa para o proximo arquivo.
	GameState.start_run(1234)


## Faz o programa inteiro ir ao ar: segura o microfone e deixa o tempo
## correr. Os improvisos estouram no prazo e caem na opcao 0, que e o
## que acontece com quem fica calado.
func _perform_live(max_steps := 6000) -> void:
	var step := 1.0 / 60.0
	var steps := 0
	while not GameState.is_live_done() and steps < max_steps:
		GameState.set_mic_held(true)
		GameState._process(step)
		steps += 1
	assert_lt(steps, max_steps, "o programa deveria terminar sozinho")


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
	_perform_live()
	watch_signals(GameState)

	assert_true(GameState.advance_phase())
	assert_eq(GameState.current_phase(), NightCycle.Phase.MORNING)
	assert_signal_emitted(GameState, "morning_ready")
	assert_true(GameState.morning_report().has("headlines"))


# --- o ao vivo ---

func test_the_program_does_not_end_by_itself() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()

	assert_eq(GameState.current_phase(), NightCycle.Phase.LIVE)
	assert_false(GameState.is_live_done(), "o programa ainda nao foi ao ar")
	assert_false(GameState.advance_phase(), "nao se sai do ar sem apresentar")


func test_entering_live_announces_the_first_block() -> void:
	GameState.advance_phase()
	_fill_program()
	watch_signals(GameState)
	GameState.advance_phase()

	assert_signal_emitted(GameState, "live_block_started")
	assert_eq(GameState.live_block_position(), 0)
	assert_eq(GameState.live_block_count(), 4, "os 4 blocos escalados vao ao ar")


func test_the_teleprompter_only_moves_with_the_mic_held() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()

	for i in 60:
		GameState._process(1.0 / 60.0)
	assert_eq(GameState.live_line_progress(), 0.0, "sem microfone o roteiro nao sobe")

	GameState.set_mic_held(true)
	for i in 30:
		GameState._process(1.0 / 60.0)
	assert_gt(GameState.live_line_progress(), 0.0)


## Duas noites iguais, uma com silencio no meio: a diferenca e o preco
## do ar morto. Comparar as duas e mais honesto do que cravar um numero,
## porque o total da noite tambem tem os deltas do enquadramento.
func test_letting_go_of_the_mic_costs_listeners() -> void:
	# Silencio longo de proposito: a manha soma as consequencias e a
	# confianca encosta no teto de 100. Com 15 segundos calados a
	# diferenca sobrevive ao clamp.
	var com_silencio := _run_one_night(15.0)
	var sem_silencio := _run_one_night(0.0)

	assert_lt(com_silencio, sem_silencio,
		"dois segundos calado custam ouvinte")


func _run_one_night(silent_seconds: float) -> int:
	GameState.start_run(1234)
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()

	if silent_seconds > 0.0:
		GameState.set_mic_held(true)
		GameState.set_mic_held(false)
		for i in int(silent_seconds * 60.0):
			GameState._process(1.0 / 60.0)

	_perform_live()
	GameState.advance_phase()
	return GameState.visible_meters()[Meters.AUDIENCE_TRUST]


func test_the_program_walks_through_every_block() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()
	watch_signals(GameState)
	_perform_live()

	assert_eq(get_signal_emit_count(GameState, "live_block_started"), 3,
		"tres emendas entre os quatro blocos")
	assert_true(GameState.is_live_done())
	assert_eq(GameState.live_block_position(), 3, "terminou no ultimo bloco")


func test_live_events_reach_the_scene() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()
	watch_signals(GameState)
	_perform_live()

	assert_gt(get_signal_emit_count(GameState, "live_events"), 0,
		"o ao vivo precisa contar o que aconteceu")


func test_a_forbidden_word_that_airs_draws_the_regime() -> void:
	# O roteiro da verdade sobre a fila tem a palavra "greve" escondida.
	GameState.advance_phase()
	GameState.place_item("n01_msg_dona_celia", 0)
	GameState.set_framing(0, FramingOption.Kind.TRUTH)
	for i in range(1, ProgramRundown.BLOCK_COUNT):
		GameState.place_item(GameState.inbox()[i].id, i)
		GameState.set_framing(i, FramingOption.Kind.DISCARD)
	GameState.advance_phase()

	var slots := GameState.live_forbidden_slots()
	assert_gt(slots.size(), 0, "o roteiro esconde uma palavra proibida")
	assert_eq(slots[0]["word"], "greve")

	_perform_live()
	GameState.advance_phase()
	assert_eq(GameState.current_phase(), NightCycle.Phase.MORNING)


func test_replacing_the_word_in_time_works_through_the_autoload() -> void:
	GameState.advance_phase()
	GameState.place_item("n01_msg_dona_celia", 0)
	GameState.set_framing(0, FramingOption.Kind.TRUTH)
	for i in range(1, ProgramRundown.BLOCK_COUNT):
		GameState.place_item(GameState.inbox()[i].id, i)
		GameState.set_framing(i, FramingOption.Kind.DISCARD)
	GameState.advance_phase()

	assert_true(GameState.replace_word(0))
	assert_string_contains(GameState.live_line_text(1), "paralisação voluntária")


# --- o invariante de vazamento ---

func test_meter_changed_only_fires_for_visible_meters() -> void:
	GameState.advance_phase()
	_fill_program()
	GameState.advance_phase()
	_perform_live()
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
