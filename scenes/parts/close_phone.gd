extends Control

## O celular, como celular: um aparelho em pé, com a data de hoje, a lista
## de conversas e, dentro de cada uma, as mensagens chegando (ADR 0013).
##
## Duas telas no mesmo aparelho, como em qualquer aplicativo de mensagem:
## a lista, com a última fala e a hora dela, e a conversa aberta. Quem
## manda as mensagens chegarem é a lógica, no horário dela — abrir o
## aparelho não dispara nada.

signal thread_opened(item_id: String)
signal reply_chosen(index: int)
signal claim_marked(claim_id: String)
signal close_requested()
signal back_requested()

@export var bubble_scene: PackedScene
@export var row_scene: PackedScene

@onready var _today: Label = $Today
@onready var _clock: Label = $Clock
@onready var _title: Label = $Title
@onready var _back: Button = $BackButton
@onready var _close: Button = $CloseButton
@onready var _list_scroll: ScrollContainer = $ListScroll
@onready var _list: VBoxContainer = $ListScroll/List
@onready var _chat_scroll: ScrollContainer = $ChatScroll
@onready var _thread: VBoxContainer = $ChatScroll/Thread
@onready var _claims: HBoxContainer = $Claims
@onready var _replies: VBoxContainer = $Replies


func _ready() -> void:
	_close.pressed.connect(func() -> void: close_requested.emit())
	_back.pressed.connect(func() -> void: back_requested.emit())


func set_today(date: String) -> void:
	_today.text = date


## A hora do programa, no canto de cima. Anda enquanto a noite anda.
func set_clock(hour: String) -> void:
	_clock.text = hour


## A lista de conversas. Cada linha traz quem falou, o começo da última
## fala, a hora dela e quantas não lidas — o suficiente para decidir o que
## abrir primeiro.
func show_list(threads: Array) -> void:
	_title.text = "MENSAGENS"
	_back.visible = false
	_list_scroll.visible = true
	_chat_scroll.visible = false
	_claims.visible = false
	_replies.visible = false
	_clear(_list)

	for thread in threads:
		# Arrastável: a conversa sai do celular direto para um bloco do
		# programa, que era o que os chips de avatar faziam antes.
		var row: Button = row_scene.instantiate()
		_list.add_child(row)
		var unread: int = int(thread.get("unread", 0))
		var mark: String = "(%d) " % unread if unread > 0 else ""
		row.setup(String(thread["item_id"]),
			"%s%s  %s
%s" % [mark, thread["name"], thread["at"],
				_one_line(String(thread["preview"]))],
			true)
		# Linha de altura fixa e prévia cortada: a lista é para escolher o
		# que abrir, não para ler a mensagem inteira.
		row.clip_text = true
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size = Vector2(0, 21)
		row.row_pressed.connect(func(row_id: String) -> void: thread_opened.emit(row_id))


## A conversa aberta: balões na ordem, o que há para conferir e, quando
## for a sua vez, o que você pode responder.
func show_chat(
	who: String,
	messages: Array,
	replies: Array,
	available: Array,
	claims: Array,
	contradictions: Array
) -> void:
	_title.text = who
	_back.visible = true
	_list_scroll.visible = false
	_chat_scroll.visible = true
	_clear(_thread)
	_clear(_claims)
	_clear(_replies)

	var width: float = _chat_scroll.size.x - 6.0
	# Toda fala mostra a hora em que foi mandada, sem agrupar: é assim que
	# se lê uma conversa fora de ordem depois.
	for message in messages:
		var bubble: Control = bubble_scene.instantiate()
		_thread.add_child(bubble)
		bubble.setup(message.text, message.from_me, message.at, width * 0.82)

	for claim in claims:
		var chip: Button = row_scene.instantiate()
		_claims.add_child(chip)
		var caught: bool = contradictions.has(claim.id)
		chip.setup(claim.id, ("! " if caught else "? ") + claim.excerpt, false)
		chip.clip_text = true
		chip.custom_minimum_size = Vector2(34, 10)
		chip.row_pressed.connect(func(row_id: String) -> void: claim_marked.emit(row_id))
	_claims.visible = not claims.is_empty()

	for index in replies.size():
		var row: Button = row_scene.instantiate()
		_replies.add_child(row)
		var reply: ReplyOption = replies[index]
		var locked: bool = not bool(available[index])
		row.setup(str(index), reply.text if not locked else reply.text + " — conferir antes", false)
		row.disabled = locked
		row.clip_text = false
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.custom_minimum_size = Vector2(0, 9)
		row.row_pressed.connect(func(row_id: String) -> void: reply_chosen.emit(int(row_id)))
	_replies.visible = not replies.is_empty()


## A conversa cresce para baixo: o jogador tem de ver a última fala.
func scroll_to_end() -> void:
	await get_tree().process_frame
	_chat_scroll.scroll_vertical = int(_thread.size.y) + 128


## A prévia é só o começo da última fala.
func _one_line(text: String) -> String:
	var flat := text.replace("
", " ")
	return flat if flat.length() <= 26 else flat.substr(0, 25) + "..."


func showing_chat() -> bool:
	return _chat_scroll.visible


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
