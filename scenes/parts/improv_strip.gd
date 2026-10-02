extends Control

## O roteiro parou e o relógio corre. Aqui o enquadramento vira fala.
##
## Não decide nada: mostra as opções que o autoload entregou e avisa qual
## foi clicada. Quem conta o tempo é o LiveBroadcast, do outro lado.

signal option_chosen(option_index: int)

@export var row_scene: PackedScene

@onready var _prompt: Label = $Prompt
@onready var _clock: Label = $Clock
@onready var _list: VBoxContainer = $Scroll/List


func show_improv(prompt: String, options: Array) -> void:
	_prompt.text = prompt

	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

	for index in options.size():
		var option: ImprovOption = options[index]
		var row: Button = row_scene.instantiate()
		row.setup(str(index), option.text, false)
		row.tooltip_text = option.text
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.clip_text = false
		row.custom_minimum_size = Vector2(0, 14)
		row.row_pressed.connect(func(row_id: String) -> void: option_chosen.emit(int(row_id)))
		_list.add_child(row)


## O relógio é a pressão: sem ele o improviso vira menu.
func set_seconds_left(seconds: float) -> void:
	_clock.text = "%.1f" % maxf(seconds, 0.0)
