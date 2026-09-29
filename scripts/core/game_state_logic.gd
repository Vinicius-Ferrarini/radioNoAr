class_name GameStateLogic
extends RefCounted

var power: int = 50
var integrity: int = 50
var inconsistency: int = 0
var current_night: int = 1
var history: Array[Choice] = []


func apply_choice(choice: Choice) -> void:
	power = clampi(power + choice.power_delta, 0, 100)
	integrity = clampi(integrity + choice.integrity_delta, 0, 100)
	history.append(choice)
	current_night += 1


func is_finished(total_nights: int) -> bool:
	return current_night > total_nights


func resolve_ending() -> String:
	return EndingResolver.resolve(power)
