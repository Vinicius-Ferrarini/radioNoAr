extends Control

## A folha física que recebe automaticamente as decisões editoriais.
## Só apresenta dados preparados pelo GameState; duração e prontidão
## continuam pertencendo à lógica da aplicação (ADR 0014).

const _INK := Color(0.12, 0.09, 0.07)
const _MUTED := Color(0.38, 0.31, 0.24)
const _AMBER := Color(0.56, 0.29, 0.06)
const _RED := Color(0.58, 0.12, 0.08)

@onready var _list: VBoxContainer = $Paper/ListScroll/List
@onready var _total: Label = $Paper/Total
@onready var _warning: Label = $Paper/Warning


func show_rundown(entries: Array[Dictionary], total_seconds: float) -> void:
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
