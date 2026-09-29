extends Node

signal power_changed(new_value: int)
signal night_advanced(new_night: int)
signal game_ended(ending_id: String)

const TOTAL_NIGHTS := 3
const EVENTS_DIR := "res://data/events/"

var _logic := GameStateLogic.new()
var _events: Array[RadioEvent] = []
var _last_ending_id: String = ""


func _ready() -> void:
	load_events()


func load_events() -> void:
	_events.clear()
	var dir := DirAccess.open(EVENTS_DIR)
	if dir == null:
		return

	var file_names: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			file_names.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	file_names.sort()

	for name in file_names:
		var event: RadioEvent = load(EVENTS_DIR + name)
		_events.append(event)


func get_current_event() -> RadioEvent:
	var index := _logic.current_night - 1
	if index < 0 or index >= _events.size():
		return null
	return _events[index]


func apply_choice(choice: Choice) -> void:
	_logic.apply_choice(choice)
	power_changed.emit(_logic.power)
	if _logic.is_finished(TOTAL_NIGHTS):
		_last_ending_id = _logic.resolve_ending()
		game_ended.emit(_last_ending_id)
	else:
		night_advanced.emit(_logic.current_night)


func reset_run() -> void:
	_logic = GameStateLogic.new()
	_last_ending_id = ""


func get_power() -> int:
	return _logic.power


func get_current_night() -> int:
	return _logic.current_night


func get_last_ending_id() -> String:
	return _last_ending_id
