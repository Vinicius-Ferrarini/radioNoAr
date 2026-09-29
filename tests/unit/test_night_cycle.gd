extends GutTest

const NIGHT_ONE := "res://data/nights/night_01.tres"


func _make_framing(kind: int, deltas := {}, consequence_ids: Array[String] = []) -> FramingOption:
	var framing := FramingOption.new()
	framing.kind = kind
	framing.immediate_deltas = deltas
	framing.consequence_ids = consequence_ids
	return framing


func _make_item(id: String, sender_id: String, framings: Array[FramingOption], fraudulent := false) -> BroadcastItem:
	var item := BroadcastItem.new()
	item.id = id
	item.sender_id = sender_id
	item.type = BroadcastItem.ItemType.SPOTLIGHT
	item.channel = BroadcastItem.Channel.PHONE
	item.headline = "manchete de %s" % id
	item.body = "corpo"
	item.framings = framings
	item.is_fraudulent = fraudulent
	return item


func _make_night(items: Array[BroadcastItem], quota := 1) -> NightDefinition:
	var night := NightDefinition.new()
	night.night = 1
	night.era = NightDefinition.Era.PHONE
	night.inbox = items
	night.propaganda_quota = quota
	return night


func _plain_items(count: int) -> Array[BroadcastItem]:
	var items: Array[BroadcastItem] = []
	for i in count:
		var framings: Array[FramingOption] = [
			_make_framing(FramingOption.Kind.TRUTH, {Meters.AUDIENCE_TRUST: 1}),
			_make_framing(FramingOption.Kind.DISCARD),
		]
		items.append(_make_item("i%d" % i, "remetente_%d" % i, framings))
	return items


func _fill_and_frame(cycle: NightCycle, kind := FramingOption.Kind.TRUTH) -> void:
	var rundown := cycle.rundown()
	var inbox := cycle.inbox()
	for i in ProgramRundown.BLOCK_COUNT:
		rundown.place(inbox[i], i)
		rundown.set_framing(i, kind)


# --- fases ---

func test_starts_in_triage() -> void:
	var cycle := NightCycle.new(_make_night(_plain_items(6)), RunState.new())
	assert_eq(cycle.phase(), NightCycle.Phase.TRIAGE)


func test_triage_can_always_advance() -> void:
	var cycle := NightCycle.new(_make_night(_plain_items(6)), RunState.new())
	assert_true(cycle.can_advance(), "nao conferir nada tambem e uma escolha")
	assert_eq(cycle.advance(), NightCycle.Phase.RUNDOWN)


func test_rundown_cannot_advance_before_it_is_ready() -> void:
	var cycle := NightCycle.new(_make_night(_plain_items(6)), RunState.new())
	cycle.advance()

	assert_false(cycle.can_advance(), "programa incompleto nao vai ao ar")
	assert_eq(cycle.advance(), NightCycle.Phase.RUNDOWN, "advance nao deveria mudar a fase")


func test_rundown_advances_once_the_program_is_ready() -> void:
	var cycle := NightCycle.new(_make_night(_plain_items(6)), RunState.new())
	cycle.advance()
	_fill_and_frame(cycle)

	assert_true(cycle.can_advance())
	assert_eq(cycle.advance(), NightCycle.Phase.LIVE)


func test_the_night_runs_from_triage_to_day() -> void:
	var cycle := NightCycle.new(_make_night(_plain_items(6)), RunState.new())
	cycle.advance()
	_fill_and_frame(cycle)
	assert_eq(cycle.advance(), NightCycle.Phase.LIVE)
	assert_eq(cycle.advance(), NightCycle.Phase.MORNING)
	assert_eq(cycle.advance(), NightCycle.Phase.DAY)
	assert_eq(cycle.advance(), NightCycle.Phase.DONE)
	assert_eq(cycle.advance(), NightCycle.Phase.DONE, "DONE e o fim da linha")


func test_notebook_gets_the_entries_of_the_night_at_the_start() -> void:
	var run := RunState.new()
	var night := _make_night(_plain_items(6))
	var entry := NotebookEntry.new()
	entry.id = "e_nova"
	entry.category = NotebookEntry.Category.CURFEW
	entry.key = "centro"
	entry.text = "toque de recolher"
	night.new_notebook_entries = [entry] as Array[NotebookEntry]

	NightCycle.new(night, run)
	assert_true(run.notebook().has_entry("e_nova"),
		"as regras novas da noite entram no caderno antes da triagem")


# --- resolver o ao vivo ---

func test_framing_deltas_are_applied_when_leaving_live() -> void:
	var run := RunState.new()
	var cycle := NightCycle.new(_make_night(_plain_items(6)), run)
	cycle.advance()
	_fill_and_frame(cycle)
	cycle.advance()

	var before: int = run.meters().get_value(Meters.AUDIENCE_TRUST)
	cycle.advance()
	assert_eq(run.meters().get_value(Meters.AUDIENCE_TRUST), before + 4,
		"os 4 blocos somam +1 de confianca cada")


func test_discarded_blocks_do_not_apply_their_deltas() -> void:
	var run := RunState.new()
	var cycle := NightCycle.new(_make_night(_plain_items(6)), run)
	cycle.advance()
	_fill_and_frame(cycle, FramingOption.Kind.DISCARD)
	cycle.advance()

	var before: int = run.meters().get_value(Meters.AUDIENCE_TRUST)
	cycle.advance()
	assert_eq(run.meters().get_value(Meters.AUDIENCE_TRUST), before,
		"o que nao foi ao ar nao mexe em medidor")


func test_aired_items_go_into_the_history() -> void:
	var run := RunState.new()
	var cycle := NightCycle.new(_make_night(_plain_items(6)), run)
	cycle.advance()
	_fill_and_frame(cycle)
	cycle.advance()
	cycle.advance()

	assert_eq(run.aired_history().size(), 4, "os 4 blocos que foram ao ar")


# --- consequencias ---

func test_consequences_are_scheduled_and_never_land_on_the_same_night() -> void:
	var run := RunState.new()
	var framings: Array[FramingOption] = [
		_make_framing(FramingOption.Kind.TRUTH, {}, ["c_nome_no_ar"] as Array[String]),
		_make_framing(FramingOption.Kind.DISCARD),
	]
	var items := _plain_items(6)
	items[0] = _make_item("com_consequencia", "alguem", framings)

	var cycle := NightCycle.new(_make_night(items), run)
	cycle.advance()
	_fill_and_frame(cycle)
	cycle.advance()
	cycle.advance()

	assert_eq(run.queue().pending_count(), 1, "a consequencia foi agendada")
	assert_eq(run.queue().peek_due(1).size(), 0, "e nao vence nesta noite")
	assert_eq(run.queue().peek_due(2).size(), 1, "vence na noite seguinte")


func test_fraud_aired_condition_is_resolved_when_scheduling() -> void:
	var run := RunState.new()
	var framings: Array[FramingOption] = [
		_make_framing(FramingOption.Kind.TRUTH, {}, ["c_denuncia_no_ar"] as Array[String]),
		_make_framing(FramingOption.Kind.DISCARD),
	]
	var items := _plain_items(6)
	items[0] = _make_item("falso", "mentiroso", framings, true)

	var cycle := NightCycle.new(_make_night(items), run)
	cycle.advance()
	_fill_and_frame(cycle)
	cycle.advance()
	cycle.advance()

	assert_eq(run.queue().pending_count(), 1,
		"item falso que foi ao ar aciona a consequencia de FRAUD_AIRED")


func test_fraud_aired_condition_does_not_fire_for_a_truthful_item() -> void:
	var run := RunState.new()
	var framings: Array[FramingOption] = [
		_make_framing(FramingOption.Kind.TRUTH, {}, ["c_denuncia_no_ar"] as Array[String]),
		_make_framing(FramingOption.Kind.DISCARD),
	]
	var items := _plain_items(6)
	items[0] = _make_item("verdadeiro", "honesto", framings, false)

	var cycle := NightCycle.new(_make_night(items), run)
	cycle.advance()
	_fill_and_frame(cycle)
	cycle.advance()
	cycle.advance()

	assert_eq(run.queue().pending_count(), 0,
		"a condicao FRAUD_AIRED so vale para item falso")


func test_morning_applies_what_is_due_and_reports_it() -> void:
	var run := RunState.new()
	var effect := ConsequenceEffect.new()
	effect.id = "e_manha"
	effect.delay_nights = 1
	effect.condition = ConsequenceEffect.Condition.ALWAYS
	effect.meter_deltas = {Meters.AUDIENCE_TRUST: -10}
	effect.morning_headline = "MANCHETE DA MANHA"
	effect.morning_letter = "uma carta"
	effect.flags_set = ["marca"] as Array[String]

	# Agendada como se fosse da noite anterior.
	run.queue().schedule(effect, 0)

	var cycle := NightCycle.new(_make_night(_plain_items(6)), run)
	cycle.advance()
	_fill_and_frame(cycle, FramingOption.Kind.DISCARD)
	cycle.advance()
	cycle.advance()

	var report := cycle.morning_report()
	assert_eq(report["headlines"].size(), 1)
	assert_eq(report["headlines"][0], "MANCHETE DA MANHA")
	assert_eq(report["letters"].size(), 1)
	assert_eq(run.meters().get_value(Meters.AUDIENCE_TRUST), 40,
		"a consequencia da noite anterior cobra o preco agora")
	assert_true(run.flags().has("marca"))


func test_morning_report_is_stable_when_asked_twice() -> void:
	var run := RunState.new()
	var effect := ConsequenceEffect.new()
	effect.id = "e_manha"
	effect.delay_nights = 1
	effect.meter_deltas = {Meters.AUDIENCE_TRUST: -10}
	effect.morning_headline = "MANCHETE"
	run.queue().schedule(effect, 0)

	var cycle := NightCycle.new(_make_night(_plain_items(6)), run)
	cycle.advance()
	_fill_and_frame(cycle, FramingOption.Kind.DISCARD)
	cycle.advance()
	cycle.advance()

	cycle.morning_report()
	cycle.morning_report()
	assert_eq(run.meters().get_value(Meters.AUDIENCE_TRUST), 40,
		"ler o relatorio duas vezes nao pode cobrar duas vezes")


func test_morning_adds_notebook_entries_from_the_consequence() -> void:
	var run := RunState.new()
	var effect := ConsequenceEffect.new()
	effect.id = "e_manha"
	effect.delay_nights = 1
	effect.notebook_entry_ids = ["entry_j_toledo_mentiu"] as Array[String]
	run.queue().schedule(effect, 0)

	var cycle := NightCycle.new(_make_night(_plain_items(6)), run)
	cycle.advance()
	_fill_and_frame(cycle, FramingOption.Kind.DISCARD)
	cycle.advance()
	cycle.advance()
	cycle.morning_report()

	assert_true(run.notebook().has_entry("entry_j_toledo_mentiu"),
		"a manha ensina coisa nova ao caderno")


# --- inconsistencia ---

func test_contradicting_yourself_about_the_same_sender_costs_inconsistency() -> void:
	var run := RunState.new()
	var inflame: Array[FramingOption] = [
		_make_framing(FramingOption.Kind.INFLAME),
		_make_framing(FramingOption.Kind.SOFTEN),
		_make_framing(FramingOption.Kind.DISCARD),
	]
	var items := _plain_items(6)
	items[0] = _make_item("noite_1", "dona_celia", inflame)

	var first := NightCycle.new(_make_night(items), run)
	first.advance()
	first.rundown().place(items[0], 0)
	first.rundown().set_framing(0, FramingOption.Kind.INFLAME)
	for i in range(1, ProgramRundown.BLOCK_COUNT):
		first.rundown().place(items[i], i)
		first.rundown().set_framing(i, FramingOption.Kind.TRUTH)
	first.advance()
	first.advance()

	assert_eq(run.meters().get_value(Meters.INCONSISTENCY), 0, "na primeira vez nao ha contradicao")

	run.advance_night()
	var second_items := _plain_items(6)
	second_items[0] = _make_item("noite_2", "dona_celia", inflame)
	var second := NightCycle.new(_make_night(second_items), run)
	second.advance()
	second.rundown().place(second_items[0], 0)
	second.rundown().set_framing(0, FramingOption.Kind.SOFTEN)
	for i in range(1, ProgramRundown.BLOCK_COUNT):
		second.rundown().place(second_items[i], i)
		second.rundown().set_framing(i, FramingOption.Kind.TRUTH)
	second.advance()
	second.advance()

	assert_eq(run.meters().get_value(Meters.INCONSISTENCY), 1,
		"inflamar e depois suavizar o mesmo remetente e se contradizer")


func test_repeating_the_same_framing_is_not_inconsistent() -> void:
	var run := RunState.new()
	for night in 2:
		var items := _plain_items(6)
		var framings: Array[FramingOption] = [
			_make_framing(FramingOption.Kind.INFLAME),
			_make_framing(FramingOption.Kind.DISCARD),
		]
		items[0] = _make_item("item_%d" % night, "dona_celia", framings)

		var cycle := NightCycle.new(_make_night(items), run)
		cycle.advance()
		cycle.rundown().place(items[0], 0)
		cycle.rundown().set_framing(0, FramingOption.Kind.INFLAME)
		for i in range(1, ProgramRundown.BLOCK_COUNT):
			cycle.rundown().place(items[i], i)
			cycle.rundown().set_framing(i, FramingOption.Kind.TRUTH)
		cycle.advance()
		cycle.advance()
		run.advance_night()

	assert_eq(run.meters().get_value(Meters.INCONSISTENCY), 0,
		"manter a mesma posicao nao e inconsistencia")


# --- a noite 1 de verdade ---

func test_night_one_content_runs_through_the_cycle() -> void:
	var run := RunState.new()
	var night: NightDefinition = load(NIGHT_ONE)
	var cycle := NightCycle.new(night, run)

	assert_eq(run.notebook().all_entries().size(), 7, "as 7 regras da noite 1")
	assert_eq(cycle.inbox().size(), 6)

	cycle.advance()
	_fill_and_frame(cycle, FramingOption.Kind.DISCARD)
	assert_true(cycle.rundown().is_ready())
	assert_eq(cycle.advance(), NightCycle.Phase.LIVE)
	assert_eq(cycle.advance(), NightCycle.Phase.MORNING)


func test_night_one_validator_sees_the_notebook_of_the_night() -> void:
	var run := RunState.new()
	var night: NightDefinition = load(NIGHT_ONE)
	var cycle := NightCycle.new(night, run)

	var toledo: BroadcastItem = null
	for item in cycle.inbox():
		if item.id == "n01_msg_toledo":
			toledo = item
	assert_not_null(toledo)

	assert_eq(cycle.validator().link(toledo, "c_b_local", "entry_rua_aurora_evacuada"),
		Validator.Result.CONTRADICTION,
		"a denuncia cita uma rua que o caderno diz estar vazia")
