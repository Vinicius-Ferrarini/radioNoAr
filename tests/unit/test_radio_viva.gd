extends GutTest


func _script(seconds := 30.0) -> BroadcastScript:
	var line := ScriptLine.new()
	line.text = "Boa noite, bairro."
	line.read_seconds = seconds
	var script := BroadcastScript.new()
	script.lines = [line]
	return script


func _call() -> RadioCall:
	var call := RadioCall.new()
	call.caller = "Rui"
	call.transcript = "A ponte está fechada."
	call.trigger_seconds = 1.0
	call.aired_reaction = "Obrigado por me ouvir."
	call.cut_reaction = "Rui ficou na linha."
	return call


func test_truth_requires_related_evidence_not_a_suspicion_mark() -> void:
	var claim := ItemClaim.new()
	claim.id = "ponte"
	claim.key = "ponte"
	var entry := NotebookEntry.new()
	entry.id = "vistoria"
	entry.key = "ponte"
	var notebook := Notebook.new()
	notebook.add_entry(entry)
	var validator := Validator.new(notebook)
	var framing := FramingOption.new()
	framing.kind = FramingOption.Kind.TRUTH
	framing.required_claim_id = "ponte"
	var item := BroadcastItem.new()
	item.id = "boletim"
	item.claims = [claim]
	item.framings = [framing]
	var rundown = ProgramRundown.new(0, [], validator)
	rundown.place(item, 0)
	assert_eq(rundown.set_framing(0, framing.kind), ProgramRundown.PlaceResult.FRAMING_NOT_ALLOWED)
	validator.set_suspicious(item.id, true)
	assert_eq(rundown.set_framing(0, framing.kind), ProgramRundown.PlaceResult.FRAMING_NOT_ALLOWED)
	validator.link(item, claim.id, entry.id)
	assert_eq(rundown.set_framing(0, framing.kind), ProgramRundown.PlaceResult.OK)


func test_scheduled_call_can_be_cut_and_never_airs_after_cut() -> void:
	var live = LiveBroadcast.new(_script(), RandomNumberGenerator.new(), _call())
	live.set_mic_held(true)
	live.tick(1.0)
	assert_true(live.has_pending_call())
	assert_true(live.cut_call())
	live.tick(10.0)
	assert_eq(live.call_outcome(), "cut")
	assert_eq(live.reaction(), "Rui ficou na linha.")
	assert_false(live.cut_call())


func test_call_deadline_is_irreversible_and_block_waits_for_it() -> void:
	var live = LiveBroadcast.new(_script(1.0), RandomNumberGenerator.new(), _call())
	live.set_mic_held(true)
	live.tick(1.0)
	assert_false(live.is_finished())
	for i in 7:
		live.tick(1.0)
	assert_eq(live.call_outcome(), "aired")
	assert_false(live.cut_call())
	assert_true(live.is_finished())


func test_break_holds_preview_has_a_limit_and_does_not_cost_dead_air() -> void:
	var live = LiveBroadcast.new(_script(), RandomNumberGenerator.new(), _call())
	live.set_mic_held(true)
	live.tick(1.0)
	var left: float = live.call_seconds_left()
	assert_true(live.start_break("music"))
	live.set_mic_held(false)
	live.tick(6.0)
	assert_eq(live.call_seconds_left(), left)
	assert_eq(live.dead_air_penalty(), 0)
	assert_false(live.start_break("ad"))
	live.tick(1.0)
	assert_lt(live.call_seconds_left(), left)
	assert_lt(live.dead_air_penalty(), 0)


func test_negative_delta_does_not_extend_call() -> void:
	var live = LiveBroadcast.new(_script(), RandomNumberGenerator.new(), _call())
	live.set_mic_held(true)
	live.tick(1.0)
	var left: float = live.call_seconds_left()
	live.tick(-3.0)
	assert_eq(live.call_seconds_left(), left)


func test_call_trigger_counts_only_time_after_arrival() -> void:
	var live := LiveBroadcast.new(_script(), RandomNumberGenerator.new(), _call())
	live.set_mic_held(true)
	live.tick(4.0)
	assert_eq(live.call_seconds_left(), 4.0, "três segundos transcorreram depois da chegada")


func test_break_excess_delta_resumes_the_call_clock() -> void:
	var live := LiveBroadcast.new(_script(), RandomNumberGenerator.new(), _call())
	live.set_mic_held(true)
	live.tick(1.0)
	live.start_break("ad")
	live.tick(8.0)
	assert_eq(live.call_seconds_left(), 5.0, "seis segundos de intervalo e dois de prévia")
