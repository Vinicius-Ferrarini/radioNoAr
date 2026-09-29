extends GutTest


func test_starts_with_the_documented_values() -> void:
	var meters := Meters.new()
	assert_eq(meters.get_value(Meters.AUDIENCE_TRUST), 50)
	assert_eq(meters.get_value(Meters.STREET_HEAT), 30)
	assert_eq(meters.get_value(Meters.REGIME_ATTENTION), 10)
	assert_eq(meters.get_value(Meters.ALIGNMENT), 50)
	assert_eq(meters.get_value(Meters.INTEGRITY), 50)
	assert_eq(meters.get_value(Meters.INCONSISTENCY), 0)


func test_apply_returns_the_new_value() -> void:
	var meters := Meters.new()
	assert_eq(meters.apply(Meters.AUDIENCE_TRUST, 7), 57)
	assert_eq(meters.get_value(Meters.AUDIENCE_TRUST), 57)


func test_values_are_clamped_at_100() -> void:
	var meters := Meters.new()
	assert_eq(meters.apply(Meters.AUDIENCE_TRUST, 500), 100)


func test_values_are_clamped_at_0() -> void:
	var meters := Meters.new()
	assert_eq(meters.apply(Meters.ALIGNMENT, -500), 0)


func test_inconsistency_has_no_upper_limit() -> void:
	var meters := Meters.new()
	meters.apply(Meters.INCONSISTENCY, 150)
	assert_eq(meters.get_value(Meters.INCONSISTENCY), 150,
		"inconsistencia e um contador, nao tem teto")


func test_inconsistency_never_goes_below_zero() -> void:
	var meters := Meters.new()
	assert_eq(meters.apply(Meters.INCONSISTENCY, -5), 0)


func test_apply_all_returns_every_new_value() -> void:
	var meters := Meters.new()
	var result := meters.apply_all({
		Meters.AUDIENCE_TRUST: 10,
		Meters.STREET_HEAT: -5,
	})
	assert_eq(result.size(), 2)
	assert_eq(result[Meters.AUDIENCE_TRUST], 60)
	assert_eq(result[Meters.STREET_HEAT], 25)


func test_unknown_meter_is_ignored() -> void:
	var meters := Meters.new()
	assert_eq(meters.apply("medidor_que_nao_existe", 10), 0)
	assert_eq(meters.get_value("medidor_que_nao_existe"), 0)
	assert_false(meters.has_meter("medidor_que_nao_existe"))
	assert_eq(meters.snapshot().size(), Meters.all_ids().size(),
		"um id desconhecido nao pode criar medidor novo")


func test_hidden_meters_are_the_three_documented_ones() -> void:
	assert_true(Meters.is_hidden(Meters.REGIME_ATTENTION), "o regime nao tem medidor visivel")
	assert_true(Meters.is_hidden(Meters.INTEGRITY))
	assert_true(Meters.is_hidden(Meters.INCONSISTENCY))
	assert_false(Meters.is_hidden(Meters.AUDIENCE_TRUST))
	assert_false(Meters.is_hidden(Meters.STREET_HEAT))
	assert_false(Meters.is_hidden(Meters.ALIGNMENT))


func test_all_ids_lists_the_six_meters() -> void:
	assert_eq(Meters.all_ids().size(), 6)


func test_snapshot_is_a_copy() -> void:
	var meters := Meters.new()
	var snapshot := meters.snapshot()
	snapshot[Meters.AUDIENCE_TRUST] = 999
	assert_eq(meters.get_value(Meters.AUDIENCE_TRUST), 50,
		"mexer no snapshot nao pode mexer nos medidores")
