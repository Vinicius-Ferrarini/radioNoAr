extends Control

## A folha física que recebe automaticamente as decisões editoriais.
## Só apresenta dados preparados pelo GameState; duração e prontidão
## continuam pertencendo à lógica da aplicação (ADR 0014).

const _INK := Color(0.12, 0.09, 0.07)
const _MUTED := Color(0.38, 0.31, 0.24)
const _AMBER := Color(0.56, 0.29, 0.06)
const _RED := Color(0.58, 0.12, 0.08)
const _EXPANDED_SIZE := Vector2(184.0, 100.0)
const _COLLAPSED_SIZE := Vector2(82.0, 12.0)
const _EXPANDED_OFFSET := Vector2(0.0, -102.0)
const _AUTO_COLLAPSE_SECONDS := 1.05

@onready var _list: VBoxContainer = $Paper/ListScroll/List
@onready var _scroll: ScrollContainer = $Paper/ListScroll
@onready var _total: Label = $Paper/Total
@onready var _warning: Label = $Paper/Warning
@onready var _paper: NinePatchRect = $Paper
@onready var _collapsed_label: Label = $CollapsedLabel

var _collapsed: bool = true
var _known_entries: int = 0
var _home_position: Vector2
var _size_tween: Tween
var _attention_tween: Tween
var _auto_collapse_pending: bool = false


func _ready() -> void:
	_home_position = position
	gui_input.connect(_on_gui_input)
	set_collapsed(true, false)


func show_rundown(entries: Array[Dictionary], total_seconds: float) -> void:
	var received_new := entries.size() > _known_entries
	_known_entries = entries.size()
	_clear(_list)
	if entries.is_empty():
		_add_line("Aguardando sua primeira decisão...", _MUTED)
	else:
		for entry in entries:
			var discarded: bool = entry.get("discarded", false)
			var marker := "×" if discarded else "%02d" % (int(entry.get("index", 0)) + 1)
			var seconds := "" if discarded else "  %ds" % ceili(float(entry.get("seconds", 0.0)))
			var framing := "ARQUIVADO" if discarded else String(entry.get("framing", ""))
			var sender := _short(String(entry.get("sender", "")), 16)
			_add_line("%s  %s\n     %s%s" % [marker, sender, framing, seconds], _MUTED if discarded else _INK)

	_total.text = "TEMPO PREVISTO  %s" % _clock(total_seconds)
	if entries.is_empty():
		_warning.text = "Responda no celular ou decida um papel"
		_warning.add_theme_color_override("font_color", _MUTED)
	elif total_seconds < 24.0:
		_warning.text = "ROTEIRO CURTO · ainda cabe mais"
		_warning.add_theme_color_override("font_color", _AMBER)
	elif total_seconds <= 36.0:
		_warning.text = "TEMPO NA MEDIDA"
		_warning.add_theme_color_override("font_color", _INK)
	else:
		_warning.text = "ROTEIRO LONGO · você pode seguir assim"
		_warning.add_theme_color_override("font_color", _RED)
	_reset_scroll()
	if received_new:
		call_deferred("_animate_attention")


func toggle_collapsed() -> void:
	_auto_collapse_pending = false
	if _attention_tween != null:
		_attention_tween.kill()
	set_collapsed(not _collapsed)


func set_collapsed(value: bool, animated: bool = true) -> void:
	_collapsed = value
	if _size_tween != null:
		_size_tween.kill()
	var target_size := _COLLAPSED_SIZE if value else _EXPANDED_SIZE
	var target_position := _home_position if value else _home_position + _EXPANDED_OFFSET
	if not value:
		_paper.show()
		_collapsed_label.hide()
	if not animated:
		size = target_size
		position = target_position
		_paper.visible = not value
		_collapsed_label.visible = value
		return
	_size_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_size_tween.set_parallel(true)
	_size_tween.tween_property(self, "size", target_size, 0.22)
	_size_tween.tween_property(self, "position", target_position, 0.22)
	if value:
		_size_tween.chain().tween_callback(func() -> void:
			_paper.hide()
			_collapsed_label.show())


func is_collapsed() -> bool:
	return _collapsed


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		toggle_collapsed()
		accept_event()


func _animate_attention() -> void:
	if not is_inside_tree():
		return
	if _collapsed:
		set_collapsed(false)
		_auto_collapse_pending = true
		if _attention_tween != null:
			_attention_tween.kill()
		_attention_tween = create_tween()
		_attention_tween.tween_interval(_AUTO_COLLAPSE_SECONDS)
		_attention_tween.tween_callback(_finish_auto_collapse)
		return
	var must_return_to_edge := _auto_collapse_pending
	if _attention_tween != null:
		_attention_tween.kill()
	var expanded_position := _home_position + _EXPANDED_OFFSET
	position = expanded_position
	_attention_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	_attention_tween.tween_property(self, "position", expanded_position + Vector2(0, -5), 0.1)
	_attention_tween.tween_property(self, "position", expanded_position, 0.16)
	if must_return_to_edge:
		_attention_tween.tween_interval(0.75)
		_attention_tween.tween_callback(_finish_auto_collapse)


func _finish_auto_collapse() -> void:
	if _auto_collapse_pending and not _collapsed:
		_auto_collapse_pending = false
		set_collapsed(true)


func card_target_position() -> Vector2:
	return _home_position + _EXPANDED_OFFSET + Vector2(30, 30)


func _reset_scroll() -> void:
	_scroll.scroll_vertical = 0
	await get_tree().process_frame
	_scroll.scroll_vertical = 0


func _add_line(text: String, color: Color) -> void:
	var line := Label.new()
	line.text = text
	line.add_theme_color_override("font_color", color)
	line.add_theme_font_size_override("font_size", 6)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_list.add_child(line)


func _clock(seconds: float) -> String:
	var whole := ceili(seconds)
	return "%d:%02d" % [whole / 60, whole % 60]


func _short(text: String, limit: int) -> String:
	return text if text.length() <= limit else text.left(limit - 1) + "…"


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
