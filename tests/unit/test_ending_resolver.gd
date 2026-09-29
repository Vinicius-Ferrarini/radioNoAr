extends GutTest

var EndingResolver := load("res://scripts/core/ending_resolver.gd")


func test_power_66_resolves_to_repressao() -> void:
	assert_eq(EndingResolver.resolve(66), "repressao")


func test_power_65_resolves_to_cinza() -> void:
	assert_eq(EndingResolver.resolve(65), "cinza")


func test_power_34_resolves_to_reforma() -> void:
	assert_eq(EndingResolver.resolve(34), "reforma")


func test_power_35_resolves_to_cinza() -> void:
	assert_eq(EndingResolver.resolve(35), "cinza")


func test_power_50_resolves_to_cinza() -> void:
	assert_eq(EndingResolver.resolve(50), "cinza")
