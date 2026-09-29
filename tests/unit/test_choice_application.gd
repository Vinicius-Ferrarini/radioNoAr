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


func test_apply_choice_with_positive_power_delta_increases_power() -> void:
	var logic = GameStateLogic.new()
	var starting_power: int = logic.power
	logic.apply_choice(make_choice(10))
	assert_eq(logic.power, starting_power + 10, "power deveria aumentar em 10")


func test_apply_choice_with_negative_power_delta_decreases_power() -> void:
	var logic = GameStateLogic.new()
	var starting_power: int = logic.power
	logic.apply_choice(make_choice(-10))
	assert_eq(logic.power, starting_power - 10, "power deveria diminuir em 10")


func test_power_never_exceeds_100() -> void:
	var logic = GameStateLogic.new()
	logic.apply_choice(make_choice(200))
	assert_eq(logic.power, 100, "power deveria ser limitado (clamp) a 100")


func test_power_never_goes_below_0() -> void:
	var logic = GameStateLogic.new()
	logic.apply_choice(make_choice(-200))
	assert_eq(logic.power, 0, "power deveria ser limitado (clamp) a 0")


func test_apply_choice_increments_current_night_by_1() -> void:
	var logic = GameStateLogic.new()
	var starting_night: int = logic.current_night
	logic.apply_choice(make_choice(0))
	assert_eq(logic.current_night, starting_night + 1, "current_night deveria incrementar em 1")


func test_apply_choice_adds_choice_to_history() -> void:
	var logic = GameStateLogic.new()
	var choice := make_choice(0)
	logic.apply_choice(choice)
	assert_eq(logic.history.size(), 1, "history deveria ter 1 item")
	assert_eq(logic.history[0], choice, "history deveria conter a choice aplicada")
