extends Control

## O caderno do apresentador aberto na mesa. Cada linha é uma regra que
## você anotou; clicar numa linha cruza ela com o trecho que você marcou
## no item.

signal entry_chosen(entry_id: String)
signal close_requested()

@export var row_scene: PackedScene

const _INK := Color(0.07, 0.06, 0.05)

@onready var _title: Label = $Title
@onready var _list: VBoxContainer = $PageScroll/List
@onready var _close_button: Button = $CloseButton
@onready var _hint: Label = $Hint


func _ready() -> void:
	_close_button.pressed.connect(func() -> void: close_requested.emit())
	_title.add_theme_color_override("font_color", _INK)
	_hint.add_theme_color_override("font_color", _INK)


func show_notebook(night: int, entries: Array, marked_excerpt: String) -> void:
	_title.text = "CADERNO — NOITE %d" % night
	if marked_excerpt.is_empty():
		_hint.text = "Marque um trecho de um item para poder cruzar."
	else:
		_hint.text = "Cruzando: \"%s\"" % marked_excerpt

	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

	for entry in entries:
		var row: Button = row_scene.instantiate()
		row.theme_type_variation = &"PaperButton"
		row.setup(entry.id, entry.text, false)
		row.tooltip_text = entry.text
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.clip_text = false
		row.custom_minimum_size = Vector2(0, 16)
		row.row_pressed.connect(func(entry_id: String) -> void: entry_chosen.emit(entry_id))
		_list.add_child(row)
