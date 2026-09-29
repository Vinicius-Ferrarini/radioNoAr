extends GutTest

## A fatia vertical: a noite 1 de ponta a ponta, sem cena nenhuma, com
## tempo injetado e seed fixa.
##
## Substitui test_full_playthroughs.gd da v0 (ADR 0003). O que aquele
## arquivo garantia — que uma campanha inteira roda pelo autoload e
## termina num estado previsivel — continua garantido aqui, agora sobre
## o loop de verdade.

const STEP := 1.0 / 60.0
const SEED := 4242


func before_each() -> void:
	GameState.start_run(SEED, ContentLibrary.NIGHTS_DIR)


func after_all() -> void:
	GameState.start_run(SEED, ContentLibrary.NIGHTS_DIR)


## Segura o microfone do comeco ao fim. Improviso que estoura o prazo
## cai na opcao 0 — que e o que acontece com quem fica calado.
func _perform_live(max_steps := 8000) -> void:
	var steps := 0
	while not GameState.is_live_done() and steps < max_steps:
		GameState.set_mic_held(true)
		GameState._process(STEP)
		steps += 1
	assert_lt(steps, max_steps, "o programa deveria terminar sozinho")


func _schedule(program: Array) -> void:
	GameState.advance_phase()
	for block_index in program.size():
		var entry: Dictionary = program[block_index]
		assert_eq(GameState.place_item(entry["item"], block_index),
			ProgramRundown.PlaceResult.OK, "escalar %s" % entry["item"])
		assert_eq(GameState.set_framing(block_index, entry["framing"]),
			ProgramRundown.PlaceResult.OK, "enquadrar %s" % entry["item"])


func _run_night(program: Array) -> Dictionary:
	_schedule(program)
	assert_true(GameState.advance_phase(), "programa pronto deveria ir ao ar")
	_perform_live()
	assert_true(GameState.advance_phase(), "programa apresentado deveria virar manha")
	return GameState.morning_report()


## Um programa honesto: conta a verdade sobre a fila, desmente a denuncia
## falsa, diz o nome do desaparecido e le o comunicado obrigatorio.
func _honest_program() -> Array:
	return [
		{"item": "n01_propaganda_normalidade", "framing": FramingOption.Kind.AS_RECEIVED},
		{"item": "n01_msg_dona_celia", "framing": FramingOption.Kind.TRUTH},
		{"item": "n01_msg_toledo", "framing": FramingOption.Kind.TRUTH},
		{"item": "n01_carta_a_mendes", "framing": FramingOption.Kind.TRUTH},
	]


## Um programa que morde todas as iscas: le a denuncia falsa como veio,
## anuncia a entrega que e armadilha e cala sobre o suborno.
func _reckless_program() -> Array:
	return [
		{"item": "n01_propaganda_normalidade", "framing": FramingOption.Kind.AS_RECEIVED},
		{"item": "n01_msg_toledo", "framing": FramingOption.Kind.INFLAME},
		{"item": "n01_msg_valvula", "framing": FramingOption.Kind.AS_RECEIVED},
		{"item": "n01_carta_envelope_azul", "framing": FramingOption.Kind.DISCARD},
	]


# --- a noite inteira ---

func test_the_whole_night_runs_from_triage_to_morning() -> void:
	assert_eq(GameState.current_phase(), NightCycle.Phase.TRIAGE)
	var report := _run_night(_honest_program())

	assert_eq(GameState.current_phase(), NightCycle.Phase.MORNING)
	assert_true(report.has("headlines"))
	assert_true(report.has("letters"))
	assert_eq(report["night"], 1)


func test_the_same_seed_gives_the_same_night() -> void:
	var first := _run_night(_honest_program())
	GameState.start_run(SEED, ContentLibrary.NIGHTS_DIR)
	var second := _run_night(_honest_program())

	assert_eq(first["headlines"], second["headlines"], "mesma seed, mesma noite")
	assert_eq(first["letters"], second["letters"])


func test_nothing_reaches_the_player_during_the_broadcast() -> void:
	_schedule(_honest_program())
	GameState.advance_phase()

	var before := GameState.visible_meters()
	watch_signals(GameState)
	_perform_live()

	assert_eq(get_signal_emit_count(GameState, "morning_ready"), 0,
		"nenhuma manchete chega enquanto o programa esta no ar")
	assert_eq(GameState.visible_meters()[Meters.ALIGNMENT], before[Meters.ALIGNMENT],
		"o alinhamento so mexe quando a noite fecha")


# --- a manha cobra o que foi feito ---

func test_airing_the_false_denunciation_costs_the_morning() -> void:
	var report := _run_night(_reckless_program())

	var manchetes := String("|").join(PackedStringArray(report["headlines"]))
	assert_string_contains(manchetes, "PICHADA",
		"a denuncia falsa que foi ao ar volta como manchete")


func test_checking_the_denunciation_instead_gets_a_different_morning() -> void:
	var report := _run_night(_honest_program())

	var manchetes := String("|").join(PackedStringArray(report["headlines"]))
	assert_false(manchetes.contains("PICHADA"),
		"quem desmentiu a denuncia nao paga por ela")
	assert_string_contains(manchetes, "DESMENTE",
		"desmentir no ar tambem vira noticia")


func test_saying_the_missing_name_draws_the_regime() -> void:
	var honest := _run_night(_honest_program())
	var manchetes := String("|").join(PackedStringArray(honest["headlines"]))
	assert_string_contains(manchetes, "DELEGACIA",
		"dizer o nome de A. Mendes tem consequencia, boa ou ma")


func test_staying_silent_about_the_bribe_is_an_answer() -> void:
	var report := _run_night(_reckless_program())

	var cartas := String("|").join(PackedStringArray(report["letters"]))
	assert_string_contains(cartas, "combustível",
		"descartar o envelope azul e aceitar o suborno")


# --- o estado da campanha depois da noite 1 ---

func test_the_night_leaves_the_meters_moved() -> void:
	var before := GameState.visible_meters().duplicate()
	_run_night(_honest_program())
	var after := GameState.visible_meters()

	var mudou := false
	for meter_id in after:
		if after[meter_id] != before[meter_id]:
			mudou = true
	assert_true(mudou, "uma noite inteira tem que deixar marca")


func test_hidden_meters_stay_hidden_through_the_whole_night() -> void:
	watch_signals(GameState)
	_run_night(_honest_program())

	for i in get_signal_emit_count(GameState, "meter_changed"):
		var meter_id: String = get_signal_parameters(GameState, "meter_changed", i)[0]
		assert_false(Meters.is_hidden(meter_id),
			"medidor escondido vazou para a UI: %s" % meter_id)


func test_the_aired_program_is_in_the_history() -> void:
	_run_night(_honest_program())
	assert_eq(GameState.aired_history().size(), 4, "os 4 blocos que foram ao ar")


func test_the_slice_ends_where_the_written_content_ends() -> void:
	_run_night(_honest_program())
	assert_false(GameState.has_next_night(),
		"a noite 2 ainda nao foi escrita: a fatia vertical termina aqui")
	assert_false(GameState.start_next_night())
