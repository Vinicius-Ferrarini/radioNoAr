extends GutTest

## As 10 regras do ao vivo (SPEC 4.6), com tempo injetado.
##
## Nenhum teste aqui espera nada acontecer: o tempo entra por tick(), em
## passos fixos. É isso que faz a mecânica mais complexa do jogo rodar
## headless em milissegundos, sem piscar (ADR 0007).

const STEP := 1.0 / 60.0


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return rng


func _slot(word: String, char_start: int, synonym: String) -> ForbiddenWordSlot:
	var slot := ForbiddenWordSlot.new()
	slot.word = word
	slot.char_start = char_start
	slot.approved_synonym = synonym
	return slot


func _option(id: String, audience: int) -> ImprovOption:
	var option := ImprovOption.new()
	option.id = id
	option.text = "frase %s" % id
	option.framing_kind = FramingOption.Kind.TRUTH
	option.immediate_deltas = {Meters.AUDIENCE_TRUST: audience}
	return option


func _improv(id: String, limit: float, options: Array[ImprovOption]) -> ImprovPoint:
	var point := ImprovPoint.new()
	point.id = id
	point.prompt = "Diga alguma coisa."
	point.time_limit_seconds = limit
	point.options = options
	return point


func _line(text: String, seconds: float, slots: Array[ForbiddenWordSlot] = [], improv: ImprovPoint = null) -> ScriptLine:
	var line := ScriptLine.new()
	line.text = text
	line.read_seconds = seconds
	line.forbidden_slots = slots
	line.improv_point = improv
	return line


func _script(lines: Array[ScriptLine]) -> BroadcastScript:
	var script := BroadcastScript.new()
	script.id = "roteiro_de_teste"
	script.lines = lines
	return script


func _plain(line_count: int, seconds := 2.0) -> LiveBroadcast:
	var lines: Array[ScriptLine] = []
	for i in line_count:
		lines.append(_line("linha %d" % i, seconds))
	return LiveBroadcast.new(_script(lines), _rng())


func _run_for(live: LiveBroadcast, seconds: float) -> void:
	var steps := int(seconds / STEP)
	for i in steps:
		live.tick(STEP)


func _kinds(events: Array) -> Array[int]:
	var kinds: Array[int] = []
	for event in events:
		kinds.append(event["kind"])
	return kinds


# --- regra 1: o microfone liga o ar ---

func test_starts_ready_and_does_nothing_until_the_mic_is_held() -> void:
	var live := _plain(2)
	assert_eq(live.state(), LiveBroadcast.State.READY)

	_run_for(live, 10.0)
	assert_eq(live.state(), LiveBroadcast.State.READY, "sem microfone nao ha ar")
	assert_eq(live.line_index(), 0)
	assert_eq(live.line_progress(), 0.0)


func test_holding_the_mic_puts_it_on_air() -> void:
	var live := _plain(2)
	live.set_mic_held(true)
	assert_eq(live.state(), LiveBroadcast.State.ON_AIR)


# --- regra 2: o roteiro sobe e termina ---

func test_the_script_advances_line_by_line() -> void:
	var live := _plain(2, 2.0)
	live.set_mic_held(true)

	_run_for(live, 1.0)
	assert_eq(live.line_index(), 0)
	assert_almost_eq(live.line_progress(), 0.5, 0.05)

	_run_for(live, 1.1)
	assert_eq(live.line_index(), 1, "passou para a segunda linha")


func test_the_block_finishes_after_the_last_line() -> void:
	var live := _plain(2, 2.0)
	live.set_mic_held(true)
	_run_for(live, 5.0)

	assert_true(live.is_finished())
	assert_eq(live.state(), LiveBroadcast.State.FINISHED)
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.BLOCK_FINISHED))


func test_a_finished_block_stops_reacting() -> void:
	var live := _plain(1, 1.0)
	live.set_mic_held(true)
	_run_for(live, 3.0)
	live.drain_events()

	_run_for(live, 3.0)
	assert_eq(live.drain_events().size(), 0, "depois do fim nao acontece mais nada")


# --- regra 3: ar morto ---

func test_letting_go_of_the_mic_creates_dead_air() -> void:
	var live := _plain(2, 4.0)
	live.set_mic_held(true)
	_run_for(live, 1.0)
	live.set_mic_held(false)

	var progress_when_silent := live.line_progress()
	_run_for(live, 2.0)

	assert_eq(live.state(), LiveBroadcast.State.DEAD_AIR)
	assert_eq(live.line_progress(), progress_when_silent, "o roteiro nao anda no silencio")
	assert_almost_eq(live.dead_air_seconds(), 2.0, 0.05)


func test_taking_the_mic_back_resumes_the_script() -> void:
	var live := _plain(2, 4.0)
	live.set_mic_held(true)
	_run_for(live, 1.0)
	live.set_mic_held(false)
	_run_for(live, 1.0)
	live.drain_events()

	live.set_mic_held(true)
	assert_eq(live.state(), LiveBroadcast.State.ON_AIR)
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.DEAD_AIR_ENDED))

	_run_for(live, 3.5)
	assert_eq(live.line_index(), 1, "o roteiro volta de onde parou")


# --- regra 4: o silencio custa audiencia ---

func test_dead_air_costs_audience_by_the_second() -> void:
	var live := _plain(2, 10.0)
	live.set_mic_held(true)
	live.set_mic_held(false)
	_run_for(live, 3.0)

	# Faixa, e nao valor exato: somar 180 passos de 1/60 cai em
	# 2.9999999 em float, que e justamente a fronteira do floori. O que
	# importa e a regra — o silencio custa DEAD_AIR_TRUST_PER_SECOND por
	# segundo — e nao o arredondamento do ultimo microssegundo.
	assert_between(live.dead_air_penalty(), -6, -5,
		"tres segundos de silencio custam seis ouvintes")


func test_a_block_without_silence_costs_nothing() -> void:
	var live := _plain(2, 1.0)
	live.set_mic_held(true)
	_run_for(live, 3.0)
	assert_eq(live.dead_air_penalty(), 0)


# --- regras 5 e 6: improviso ---

func test_reaching_an_improv_stops_the_script_and_starts_the_clock() -> void:
	var options: Array[ImprovOption] = [_option("segura", 0), _option("arrisca", 5)]
	var lines: Array[ScriptLine] = [
		_line("abertura", 1.0),
		_line("aqui o roteiro para", 4.0, [], _improv("p1", 5.0, options)),
	]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	_run_for(live, 1.1)

	assert_eq(live.state(), LiveBroadcast.State.IMPROV)
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.IMPROV_REQUESTED))

	_run_for(live, 2.0)
	assert_eq(live.line_index(), 1, "o teleprompter nao anda durante o improviso")
	# 2.1 s de improviso corridos: os 2.0 daqui mais os 0.1 que sobraram
	# de passar da primeira linha.
	assert_almost_eq(live.improv_seconds_left(), 2.9, 0.06)


func test_choosing_in_time_resolves_and_goes_back_on_air() -> void:
	var options: Array[ImprovOption] = [_option("segura", 0), _option("arrisca", 5)]
	var lines: Array[ScriptLine] = [_line("linha", 2.0, [], _improv("p1", 5.0, options))]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	_run_for(live, 1.0)

	assert_true(live.choose_improv(1))
	assert_eq(live.state(), LiveBroadcast.State.ON_AIR)
	assert_eq(live.chosen_improvs(), ["arrisca"])
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.IMPROV_RESOLVED))


func test_running_out_of_time_takes_the_default_option() -> void:
	var options: Array[ImprovOption] = [_option("segura", 0), _option("arrisca", 5)]
	var lines: Array[ScriptLine] = [_line("linha", 2.0, [], _improv("p1", 3.0, options))]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	_run_for(live, 3.2)

	assert_eq(live.chosen_improvs(), ["segura"], "o indice 0 e o que sai quando o tempo acaba")
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.IMPROV_TIMEOUT))
	assert_eq(live.state(), LiveBroadcast.State.ON_AIR)


func test_the_chosen_line_is_handed_over_whole() -> void:
	# O ao vivo nao aplica o efeito: entrega a frase escolhida e quem
	# soma e o NightCycle, igual ao que faz com o enquadramento.
	var options: Array[ImprovOption] = [_option("segura", 0), _option("arrisca", 5)]
	var lines: Array[ScriptLine] = [_line("linha", 2.0, [], _improv("p1", 5.0, options))]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	live.choose_improv(1)

	var chosen := live.chosen_improv_options()
	assert_eq(chosen.size(), 1)
	assert_eq(chosen[0].id, "arrisca")
	assert_eq(chosen[0].immediate_deltas[Meters.AUDIENCE_TRUST], 5)


func test_choosing_an_invalid_option_is_refused() -> void:
	var options: Array[ImprovOption] = [_option("segura", 0)]
	var lines: Array[ScriptLine] = [_line("linha", 2.0, [], _improv("p1", 5.0, options))]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)

	assert_false(live.choose_improv(9))
	assert_eq(live.state(), LiveBroadcast.State.IMPROV, "continua esperando")


func test_choosing_when_there_is_no_improv_is_refused() -> void:
	var live := _plain(2)
	live.set_mic_held(true)
	assert_false(live.choose_improv(0))


# --- regra 7: silencio nao e saida do improviso ---

func test_the_improv_clock_keeps_running_in_dead_air() -> void:
	var options: Array[ImprovOption] = [_option("segura", 0), _option("arrisca", 5)]
	var lines: Array[ScriptLine] = [_line("linha", 4.0, [], _improv("p1", 3.0, options))]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	live.set_mic_held(false)

	assert_eq(live.state(), LiveBroadcast.State.DEAD_AIR)
	_run_for(live, 3.2)

	assert_eq(live.chosen_improvs(), ["segura"], "ficar calado nao adia a escolha")
	assert_eq(live.state(), LiveBroadcast.State.DEAD_AIR, "e o silencio continua sendo silencio")
	assert_gt(live.dead_air_seconds(), 3.0)


# --- regra 8: palavras proibidas ---

func test_a_forbidden_word_left_alone_becomes_an_infraction() -> void:
	var slots: Array[ForbiddenWordSlot] = [_slot("greve", 9, "paralisação voluntária")]
	var lines: Array[ScriptLine] = [_line("houve uma greve ontem", 2.0, slots)]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	_run_for(live, 2.5)

	assert_eq(live.infractions(), ["greve"])
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.FORBIDDEN_WORD_AIRED))


func test_replacing_the_word_in_time_avoids_the_infraction() -> void:
	var slots: Array[ForbiddenWordSlot] = [_slot("greve", 9, "paralisação voluntária")]
	var lines: Array[ScriptLine] = [_line("houve uma greve ontem", 2.0, slots)]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	_run_for(live, 0.5)

	assert_true(live.replace_word(0))
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.WORD_REPLACED))

	_run_for(live, 2.5)
	assert_eq(live.infractions().size(), 0)


func test_the_replaced_word_shows_up_in_the_line() -> void:
	var slots: Array[ForbiddenWordSlot] = [_slot("greve", 9, "paralisação voluntária")]
	var lines: Array[ScriptLine] = [_line("houve uma greve ontem", 2.0, slots)]
	var live := LiveBroadcast.new(_script(lines), _rng())

	assert_eq(live.line_text(0), "houve uma greve ontem")
	live.set_mic_held(true)
	live.replace_word(0)
	assert_eq(live.line_text(0), "houve uma paralisação voluntária ontem")


func test_a_word_that_already_aired_cannot_be_replaced() -> void:
	var slots: Array[ForbiddenWordSlot] = [_slot("greve", 9, "paralisação voluntária")]
	var lines: Array[ScriptLine] = [
		_line("houve uma greve ontem", 1.0, slots),
		_line("seguimos", 2.0),
	]
	var live := LiveBroadcast.new(_script(lines), _rng())
	live.set_mic_held(true)
	_run_for(live, 1.5)

	assert_false(live.replace_word(0), "a linha ja foi ao ar")
	assert_eq(live.infractions(), ["greve"])


func test_replacing_an_unknown_slot_is_refused() -> void:
	var live := _plain(1)
	live.set_mic_held(true)
	assert_false(live.replace_word(0))
	assert_false(live.replace_word(-1))


func test_forbidden_slots_are_listed_flat_for_the_teleprompter() -> void:
	var first: Array[ForbiddenWordSlot] = [_slot("greve", 0, "paralisação")]
	var second: Array[ForbiddenWordSlot] = [_slot("desaparecido", 0, "não localizado")]
	var lines: Array[ScriptLine] = [
		_line("greve", 1.0, first),
		_line("desaparecido", 1.0, second),
	]
	var live := LiveBroadcast.new(_script(lines), _rng())

	var slots := live.forbidden_slots()
	assert_eq(slots.size(), 2)
	assert_eq(slots[0]["word"], "greve")
	assert_eq(slots[0]["line_index"], 0)
	assert_eq(slots[1]["line_index"], 1)
	assert_false(slots[0]["replaced"])


# --- regra 9: a ligacao com delay de 7 segundos ---

func test_the_transcript_arrives_before_the_audience_hears_it() -> void:
	var live := _plain(3, 10.0)
	live.set_mic_held(true)
	live.queue_call("meu filho saiu e nao voltou")

	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.CALL_TRANSCRIPT))
	assert_almost_eq(live.call_seconds_left(), LiveBroadcast.CALL_DELAY_SECONDS, 0.01)

	_run_for(live, LiveBroadcast.CALL_DELAY_SECONDS - 1.0)
	assert_false(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.CALL_AIRED),
		"ainda da tempo de cortar")

	_run_for(live, 1.2)
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.CALL_AIRED))


func test_cutting_the_call_in_time_stops_it() -> void:
	var live := _plain(3, 10.0)
	live.set_mic_held(true)
	live.queue_call("o nome que nao pode ser dito")
	_run_for(live, 2.0)
	live.drain_events()

	assert_true(live.cut_call())
	assert_true(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.CALL_CUT))

	_run_for(live, 10.0)
	assert_false(_kinds(live.drain_events()).has(LiveBroadcast.EventKind.CALL_AIRED))


func test_cutting_after_it_aired_is_too_late() -> void:
	var live := _plain(3, 20.0)
	live.set_mic_held(true)
	live.queue_call("ja foi")
	_run_for(live, LiveBroadcast.CALL_DELAY_SECONDS + 0.5)

	assert_false(live.cut_call(), "o que foi ao ar foi")


func test_cutting_with_no_call_is_refused() -> void:
	var live := _plain(2)
	assert_false(live.cut_call())


# --- regra 10: o ao vivo nao mexe em medidor ---

func test_live_broadcast_never_touches_the_meters() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/core/live_broadcast.gd")
	assert_false(source.is_empty(), "live_broadcast.gd deveria existir")
	assert_false(source.contains("Meters."),
		"o ao vivo devolve deltas e infracoes; quem aplica e o NightCycle")


# --- eventos ---

func test_draining_events_empties_the_queue() -> void:
	var live := _plain(2, 1.0)
	live.set_mic_held(true)
	_run_for(live, 1.5)

	assert_gt(live.drain_events().size(), 0)
	assert_eq(live.drain_events().size(), 0, "drenar esvazia")
