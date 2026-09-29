extends GutTest


func test_starts_with_the_documented_values() -> void:
	var resources := RadioResources.new()
	assert_eq(resources.get_value(RadioResources.FUEL), 40)
	assert_eq(resources.get_value(RadioResources.PARTS), 2)
	assert_eq(resources.get_value(RadioResources.MONEY), 30)
	assert_eq(resources.get_value(RadioResources.REACH), 50)


func test_apply_returns_the_new_value() -> void:
	var resources := RadioResources.new()
	assert_eq(resources.apply({RadioResources.FUEL: -10})[RadioResources.FUEL], 30)


func test_resources_never_go_negative() -> void:
	var resources := RadioResources.new()
	assert_eq(resources.apply({RadioResources.PARTS: -50})[RadioResources.PARTS], 0)


func test_reach_is_capped_at_100() -> void:
	var resources := RadioResources.new()
	assert_eq(resources.apply({RadioResources.REACH: 500})[RadioResources.REACH], 100)


func test_fuel_money_and_parts_have_no_upper_cap() -> void:
	var resources := RadioResources.new()
	var after := resources.apply({
		RadioResources.FUEL: 500,
		RadioResources.MONEY: 500,
		RadioResources.PARTS: 500,
	})
	assert_eq(after[RadioResources.FUEL], 540)
	assert_eq(after[RadioResources.MONEY], 530)
	assert_eq(after[RadioResources.PARTS], 502)


func test_unknown_resource_is_ignored() -> void:
	var resources := RadioResources.new()
	resources.apply({"parafuso": 10})
	assert_eq(resources.snapshot().size(), 4)


func test_snapshot_is_a_copy() -> void:
	var resources := RadioResources.new()
	var snapshot := resources.snapshot()
	snapshot[RadioResources.FUEL] = 999
	assert_eq(resources.get_value(RadioResources.FUEL), 40)
