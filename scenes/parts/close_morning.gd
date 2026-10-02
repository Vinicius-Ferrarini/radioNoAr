extends Control

## A manhã: onde a conta chega.
##
## Não decide nada — mostra o relatório que o autoload entregou. O
## silêncio aqui também é informação: manhã sem manchete quer dizer que
## ninguém reagiu ao que você fez, e isso raramente é bom sinal.

signal continue_requested()

@export var row_scene: PackedScene

const _INK := Color(0.07, 0.06, 0.05)

@onready var _title: Label = $Title
@onready var _list: VBoxContainer = $Scroll/List
@onready var _continue: Button = $ContinueButton


func _ready() -> void:
	_continue.pressed.connect(func() -> void: continue_requested.emit())
	_title.add_theme_color_override("font_color", _INK)


func show_report(night: int, report: Dictionary, audience: int) -> void:
	_title.text = "MANHÃ SEGUINTE — %d OUVINTES" % audience

	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

	var headlines: Array = report.get("headlines", [])
	var letters: Array = report.get("letters", [])
	var new_entries: Array = report.get("new_entries", [])

	for headline in headlines:
		_add("JORNAL: " + String(headline))
	for letter in letters:
		_add("CHEGOU NA PORTA: " + String(letter))
	for entry_id in new_entries:
		_add("O caderno aprendeu uma coisa nova.")

	if headlines.is_empty() and letters.is_empty():
		_add("Nenhuma manchete. Ninguém escreveu. A cidade acordou como se a noite passada não tivesse existido.")

	_continue.text = "NOITE %d" % (night + 1)


func set_last_night(is_last: bool) -> void:
	_continue.disabled = false
	if is_last:
		_continue.text = "RECOMEÇAR"


func _add(text: String) -> void:
	var row: Button = row_scene.instantiate()
	row.setup("", text, false)
	row.tooltip_text = text
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.clip_text = false
	row.custom_minimum_size = Vector2(0, 16)
	row.add_theme_color_override("font_color", _INK)
	row.add_theme_color_override("font_disabled_color", _INK)
	row.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	row.disabled = true
	_list.add_child(row)
