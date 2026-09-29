extends Control

const TOTAL_NIGHTS := 3
const ENDING_SCENE := "res://scenes/ending.tscn"

@onready var night_label: Label = $NightLabel
@onready var power_bar: ProgressBar = $PowerBar
@onready var event_text: RichTextLabel = $EventText
@onready var choice_buttons: Array[Button] = [
	$Choices/Choice1,
	$Choices/Choice2,
	$Choices/Choice3,
]

var _current_choices: Array[Choice] = []


func _ready() -> void:
	GameState.power_changed.connect(_on_power_changed)
	GameState.night_advanced.connect(_on_night_advanced)
	GameState.game_ended.connect(_on_game_ended)

	for i in choice_buttons.size():
		choice_buttons[i].pressed.connect(_on_choice_pressed.bind(i))

	_refresh_power(GameState.get_power())
	_refresh_night(GameState.get_current_night())
	_show_current_event()


func _refresh_power(value: int) -> void:
	power_bar.value = value


func _refresh_night(night: int) -> void:
	night_label.text = "Noite %d de %d" % [night, TOTAL_NIGHTS]


func _show_current_event() -> void:
	var event := GameState.get_current_event()
	if event == null:
		return

	event_text.text = "[b]%s[/b]\n\n%s" % [event.headline, event.body]
	_current_choices = event.choices

	for i in choice_buttons.size():
		var button := choice_buttons[i]
		if i < _current_choices.size():
			button.text = _current_choices[i].label
			button.disabled = false
		else:
			button.disabled = true


func _on_choice_pressed(index: int) -> void:
	if index >= _current_choices.size():
		return
	GameState.apply_choice(_current_choices[index])


func _on_power_changed(new_value: int) -> void:
	_refresh_power(new_value)


func _on_night_advanced(new_night: int) -> void:
	_refresh_night(new_night)
	_show_current_event()


func _on_game_ended(_ending_id: String) -> void:
	get_tree().change_scene_to_file(ENDING_SCENE)
