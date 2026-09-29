extends GutTest


func before_each() -> void:
	GameState.load_events()
	GameState.reset_run()


func _find_choice_with_stance(event: RadioEvent, stance: int) -> Choice:
	for choice in event.choices:
		if choice.stance == stance:
			return choice
	return null


func _play_stance(stance: int) -> String:
	watch_signals(GameState)
	for i in range(3):
		var event := GameState.get_current_event()
		var choice := _find_choice_with_stance(event, stance)
		GameState.apply_choice(choice)

	return GameState.get_last_ending_id()


func test_three_attack_choices_lead_to_repressao_ending() -> void:
	assert_eq(_play_stance(Choice.Stance.ATTACK), "repressao")
	assert_signal_emitted(GameState, "game_ended")


func test_three_truth_choices_lead_to_reforma_ending() -> void:
	assert_eq(_play_stance(Choice.Stance.TRUTH), "reforma")
	assert_signal_emitted(GameState, "game_ended")


func test_three_crowd_pleasing_choices_lead_to_cinza_ending() -> void:
	assert_eq(_play_stance(Choice.Stance.CROWD_PLEASING), "cinza")
	assert_signal_emitted(GameState, "game_ended")
