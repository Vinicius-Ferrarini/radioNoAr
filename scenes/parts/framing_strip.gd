class_name FramingStrip
extends Control

## A régua de enquadramento: aparece encostada nos blocos quando você
## clica num deles. É painel de estúdio, não papel — por isso a moldura
## de metal.

signal framing_chosen(kind: int)
signal clear_requested()
signal close_requested()

@export var row_scene: PackedScene

const _LABELS := {
	FramingOption.Kind.AS_RECEIVED: "Ler como chegou",
	FramingOption.Kind.TRUTH: "Contar a verdade",
	FramingOption.Kind.SOFTEN: "Suavizar",
	FramingOption.Kind.INFLAME: "Inflamar",
	FramingOption.Kind.IRONY: "Ironizar",
	FramingOption.Kind.DISCARD: "Descartar (não vai ao ar)",
}

@onready var _title: Label = $Title
@onready var _list: HBoxContainer = $Scroll/List
@onready var _clear_button: Button = $ClearButton
@onready var _close_button: Button = $CloseButton


func _ready() -> void:
	_clear_button.pressed.connect(func() -> void: clear_requested.emit())
	_close_button.pressed.connect(func() -> void: close_requested.emit())


static func label_for(kind: int) -> String:
	return _LABELS.get(kind, "")


func show_block(block_index: int, item: BroadcastItem, chosen: int) -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

	if item == null:
		_title.text = "Bloco %d — vazio. Arraste alguém para cá." % (block_index + 1)
		_clear_button.disabled = true
		return

	_title.text = "Bloco %d — %s" % [block_index + 1, item.headline]
	_clear_button.disabled = false

	for framing in item.framings:
		var row: Button = row_scene.instantiate()
		row.setup(str(framing.kind), ("> " if framing.kind == chosen else "") + label_for(framing.kind), false)
		row.custom_minimum_size = Vector2(0, 13)
		row.clip_text = true
		row.row_pressed.connect(func(kind_id: String) -> void: framing_chosen.emit(int(kind_id)))
		_list.add_child(row)
