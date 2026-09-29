extends GutTest

var GameStateLogic := load("res://scripts/core/game_state_logic.gd")


func make_choice(power_delta: int) -> Choice:
	var choice := Choice.new()
	choice.id = "test_choice"
	choice.label = "Label"
	choice.response_text = "Response"
	choice.power_delta = power_delta
	choice.integrity_delta = 0
	choice.stance = Choice.Stance.TRUTH
	return choice


func test_three_choices_finish_run_and_resolve_repressao_ending() -> void:
	var logic = GameStateLogic.new()
	logic.apply_choice(make_choice(10))
	logic.apply_choice(make_choice(10))
	logic.apply_choice(make_choice(10))

	assert_true(logic.is_finished(3), "deveria estar terminado apos 3 escolhas")
	assert_eq(logic.resolve_ending(), "repressao", "power final (80) deveria resolver para repressao")


func test_three_choices_finish_run_and_resolve_reforma_ending() -> void:
	var logic = GameStateLogic.new()
	logic.apply_choice(make_choice(-10))
	logic.apply_choice(make_choice(-10))
	logic.apply_choice(make_choice(-10))

	assert_true(logic.is_finished(3), "deveria estar terminado apos 3 escolhas")
	assert_eq(logic.resolve_ending(), "reforma", "power final (20) deveria resolver para reforma")


func test_three_choices_finish_run_and_resolve_cinza_ending() -> void:
	var logic = GameStateLogic.new()
	logic.apply_choice(make_choice(0))
	logic.apply_choice(make_choice(0))
	logic.apply_choice(make_choice(0))

	assert_true(logic.is_finished(3), "deveria estar terminado apos 3 escolhas")
	assert_eq(logic.resolve_ending(), "cinza", "power final (50) deveria resolver para cinza")
