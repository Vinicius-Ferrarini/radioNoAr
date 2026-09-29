extends GutTest


func _make_item(id: String, sender_id: String) -> BroadcastItem:
	var item := BroadcastItem.new()
	item.id = id
	item.sender_id = sender_id
	item.type = BroadcastItem.ItemType.SPOTLIGHT
	item.headline = "manchete"
	item.body = "corpo"
	return item


func test_starts_on_night_one_with_default_campaign_length() -> void:
	var run := RunState.new()
	assert_eq(run.current_night(), 1)
	assert_eq(run.total_nights(), RunState.DEFAULT_TOTAL_NIGHTS)
	assert_eq(RunState.DEFAULT_TOTAL_NIGHTS, 21, "a campanha ate o referendo tem 21 noites")


func test_advance_night_returns_the_new_night() -> void:
	var run := RunState.new(3)
	assert_eq(run.advance_night(), 2)
	assert_eq(run.current_night(), 2)


func test_is_finished_only_after_the_last_night() -> void:
	var run := RunState.new(3)
	assert_false(run.is_finished())
	run.advance_night()
	run.advance_night()
	assert_false(run.is_finished(), "a noite 3 ainda e noite de programa")
	run.advance_night()
	assert_true(run.is_finished())


func test_owns_meters_notebook_queue_and_resources() -> void:
	var run := RunState.new()
	assert_not_null(run.meters())
	assert_not_null(run.notebook())
	assert_not_null(run.queue())
	assert_not_null(run.resources())


func test_same_seed_produces_the_same_random_sequence() -> void:
	var first := RunState.new(21, 12345)
	var second := RunState.new(21, 12345)
	var third := RunState.new(21, 999)

	var a := first.rng().randi()
	var b := second.rng().randi()
	var c := third.rng().randi()

	assert_eq(a, b, "mesma seed tem que dar a mesma sequencia")
	assert_ne(a, c, "seeds diferentes nao deveriam coincidir")


func test_flags_start_empty_and_can_be_set() -> void:
	var run := RunState.new()
	assert_eq(run.flags().size(), 0)
	run.set_flag("aceitou_suborno")
	assert_true(run.flags().has("aceitou_suborno"))


func test_setting_the_same_flag_twice_is_harmless() -> void:
	var run := RunState.new()
	run.set_flag("x")
	run.set_flag("x")
	assert_eq(run.flags().size(), 1)


func test_record_aired_writes_the_history() -> void:
	var run := RunState.new()
	run.record_aired(_make_item("i1", "dona_celia"), FramingOption.Kind.INFLAME)

	var history := run.aired_history()
	assert_eq(history.size(), 1)
	assert_eq(history[0]["item_id"], "i1")
	assert_eq(history[0]["sender_id"], "dona_celia")
	assert_eq(history[0]["framing_kind"], FramingOption.Kind.INFLAME)
	assert_eq(history[0]["night"], 1)


func test_history_records_the_night_it_happened() -> void:
	var run := RunState.new()
	run.record_aired(_make_item("i1", "a"), FramingOption.Kind.TRUTH)
	run.advance_night()
	run.record_aired(_make_item("i2", "b"), FramingOption.Kind.TRUTH)

	var history := run.aired_history()
	assert_eq(history[0]["night"], 1)
	assert_eq(history[1]["night"], 2)


func test_aired_history_is_a_copy() -> void:
	var run := RunState.new()
	run.record_aired(_make_item("i1", "a"), FramingOption.Kind.TRUTH)
	var history := run.aired_history()
	history.clear()
	assert_eq(run.aired_history().size(), 1, "ninguem escreve no historico por fora")
