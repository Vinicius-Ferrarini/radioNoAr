extends Button

## Uma linha de lista: item da inbox, entrada do caderno ou afirmação a
## conferir. Só avisa que foi clicada; quem decide o que isso significa é
## a cena da mesa, que pergunta ao GameState.
##
## Quando arrastável, entrega o id do item para os blocos do programa —
## via _get_drag_data, que é o mecanismo de arrastar do Godot (nada de
## rastrear o mouse à mão).

signal row_pressed(row_id: String)

const DRAG_KIND := "inbox_item"

var _row_id: String = ""
var _draggable: bool = false


func _ready() -> void:
	pressed.connect(_on_pressed)


func setup(row_id: String, row_text: String, draggable: bool = false) -> void:
	_row_id = row_id
	_draggable = draggable
	text = row_text


## Um chip só de foto: é assim que o jogador arrasta uma pessoa para um
## bloco do programa, em vez de arrastar uma linha de lista.
func setup_avatar(row_id: String, avatar: Texture2D, hint: String, draggable: bool = false) -> void:
	_row_id = row_id
	_draggable = draggable
	text = ""
	icon = avatar
	tooltip_text = hint
	custom_minimum_size = Vector2(36, 36)
	expand_icon = true


func row_id() -> String:
	return _row_id


## O que a linha entrega quando arrastada. Separado de _get_drag_data
## porque set_drag_preview() so pode ser chamado durante um arrasto de
## verdade — se o payload morasse la, nao haveria como testa-lo.
func drag_payload() -> Variant:
	if not _draggable:
		return null
	return {"kind": DRAG_KIND, "item_id": _row_id}


func _get_drag_data(_at_position: Vector2) -> Variant:
	var payload: Variant = drag_payload()
	if payload == null:
		return null

	var preview := Label.new()
	preview.text = text
	set_drag_preview(preview)
	return payload


func _on_pressed() -> void:
	row_pressed.emit(_row_id)
