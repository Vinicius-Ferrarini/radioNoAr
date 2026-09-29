extends GutTest

## Fase 2 (ADR 0013): a linha atende uma ligação por vez e quem chega
## ocupado espera na fila; a palavra proibida tem prazo até a leitura
## passar por ela. Só lógica pura aqui.


func _line(text: String, seconds: float, slots: Array = []) -> ScriptLine:
	var line := ScriptLine.new()
	line.text = text
	line.read_seconds = seconds
	var typed: Array[ForbiddenWordSlot] = []
	for slot in slots:
		typed.append(slot)
	line.forbidden_slots = typed
	return line


func _script(lines: Array) -> BroadcastScript:
	var broadcast := BroadcastScript.new()
	var typed: Array[ScriptLine] = []
	for line in lines:
		typed.append(line)
	broadcast.lines = typed
	return broadcast


func _call(caller: String, trigger: float) -> RadioCall:
	var call := RadioCall.new()
	call.caller = caller
	call.transcript = "Fala do %s." % caller
	call.trigger_seconds = trigger
	call.aired_reaction = "%s foi ao ar." % caller
	call.cut_reaction = "%s foi cortado." % caller
	return call


func _live(calls: Array, seconds := 60.0) -> LiveBroadcast:
	var typed: Array[RadioCall] = []
	for call in calls:
		typed.append(call)
	var live := LiveBroadcast.new(
		_script([_line("Boa noite, bairro.", seconds)]),
		RandomNumberGenerator.new(), typed)
	live.set_mic_held(true)
	return live


# --- a fila da linha ---

func test_the_line_takes_one_call_at_a_time() -> void:
	var live := _live([_call("Rui", 1.0), _call("Célia", 2.0)])
	live.tick(1.0)
	assert_eq(live.caller(), "Rui", "o primeiro a chegar entra na prévia")
	assert_eq(live.calls_waiting(), 0)

	live.tick(1.0)
	assert_eq(live.caller(), "Rui", "a linha continua ocupada")
	assert_eq(live.calls_waiting(), 1, "a Célia espera")


func test_cutting_frees_the_line_for_whoever_is_waiting() -> void:
	var live := _live([_call("Rui", 1.0), _call("Célia", 2.0)])
	live.tick(2.0)
	assert_eq(live.calls_waiting(), 1)

	assert_true(live.cut_call())
	assert_eq(live.caller(), "Célia", "cortar um passa a linha para o próximo")
	assert_eq(live.calls_waiting(), 0)
	assert_eq(live.call_seconds_left(), LiveBroadcast.CALL_DELAY_SECONDS,
		"a prévia da Célia começa do zero")


func test_airing_one_also_frees_the_line() -> void:
	var live := _live([_call("Rui", 1.0), _call("Célia", 2.0)])
	live.tick(2.0)
	live.tick(LiveBroadcast.CALL_DELAY_SECONDS)
	assert_eq(live.caller(), "Célia")
	assert_eq(live.call_outcome(), "aired", "o Rui foi ao ar sozinho")


func test_each_call_carries_its_own_outcome() -> void:
	var live := _live([_call("Rui", 1.0), _call("Célia", 2.0)])
	live.tick(2.0)
	live.cut_call()
	live.tick(LiveBroadcast.CALL_DELAY_SECONDS)

	var results := live.call_results()
	assert_eq(results.size(), 2, "as duas ligações se resolveram")
	assert_eq(results[0]["call"].caller, "Rui")
	assert_eq(results[0]["outcome"], "cut")
	assert_eq(results[1]["call"].caller, "Célia")
	assert_eq(results[1]["outcome"], "aired")


func test_the_block_does_not_end_with_a_call_still_in_the_queue() -> void:
	# Roteiro curtíssimo e ligações tardias: o bloco espera as duas.
	var live := _live([_call("Rui", 1.0), _call("Célia", 2.0)], 2.0)
	for i in 4:
		live.tick(1.0)
	assert_false(live.is_finished(), "o bloco não fecha com gente na linha")

	for i in 20:
		live.tick(1.0)
	assert_true(live.is_finished())
	assert_eq(live.call_results().size(), 2, "nenhuma ligação se perdeu")


func test_a_waiting_call_announces_itself() -> void:
	var live := _live([_call("Rui", 1.0), _call("Célia", 2.0)])
	live.tick(1.0)
	live.drain_events()
	live.tick(1.0)

	var kinds: Array[int] = []
	for event in live.drain_events():
		kinds.append(int(event["kind"]))
	assert_true(kinds.has(LiveBroadcast.EventKind.CALL_WAITING),
		"o telefone tem de avisar que tocou, mesmo com a linha ocupada")


# --- o prazo da palavra proibida ---

func _slot(word: String, synonym: String, char_start: int) -> ForbiddenWordSlot:
	var slot := ForbiddenWordSlot.new()
	slot.word = word
	slot.approved_synonym = synonym
	slot.char_start = char_start
	return slot


func _with_word() -> LiveBroadcast:
	# 36 caracteres em 10 s. "greve" ocupa os caracteres 2 a 7, ou seja
	# termina a 19% da linha: vai ao ar por volta de 1,9 s.
	var text := "A greve de hoje parou o bairro todo."
	var live := LiveBroadcast.new(
		_script([_line(text, 10.0, [_slot("greve", "paralisação", text.find("greve"))])]),
		RandomNumberGenerator.new(), [] as Array[RadioCall])
	live.set_mic_held(true)
	return live


func test_the_word_airs_when_the_reading_passes_it() -> void:
	var live := _with_word()
	live.tick(1.0)
	assert_eq(live.infractions().size(), 0, "a leitura ainda não chegou na palavra")

	live.tick(1.5)
	assert_eq(live.infractions(), ["greve"],
		"passou pela palavra: saiu no ar, sem esperar o fim da linha")


func test_swapping_before_the_sweep_arrives_saves_you() -> void:
	var live := _with_word()
	live.tick(1.0)
	assert_true(live.replace_word(0))
	live.tick(9.0)
	assert_eq(live.infractions().size(), 0, "trocada a tempo, não há infração")
	assert_string_contains(live.line_text(0), "paralisação")


func test_swapping_after_the_sweep_is_too_late() -> void:
	var live := _with_word()
	live.tick(2.5)
	assert_eq(live.infractions(), ["greve"])
	assert_false(live.replace_word(0), "não se desdiz o que já saiu")
