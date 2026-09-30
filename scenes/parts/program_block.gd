extends NinePatchRect

## Um dos 4 blocos do programa. Recebe item arrastado e avisa quando é
## escolhido. Não sabe nada sobre cota nem sobre enquadramento: só
## reporta e mostra o que lhe mandam mostrar.

signal item_dropped(item_id: String, block_index: int)
signal block_clicked(block_index: int)

@export var block_index: int = 0

@onready var _label: Label = $Label


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("kind", "") == "inbox_item"


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_dropped.emit(String(data["item_id"]), block_index)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		block_clicked.emit(block_index)


func show_empty(placeholder: String) -> void:
	_label.text = "%s\nLIVRE" % placeholder


func show_item(headline: String, framing_label: String) -> void:
	if framing_label.is_empty():
		_label.text = headline
	else:
		_label.text = "%s\n%s" % [headline, framing_label]
