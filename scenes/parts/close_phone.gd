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
@export var thread_row_scene: PackedScene

@onready var _today: Label = $Today
@onready var _clock: Label = $Clock
@onready var _title: Label = $Title
@onready var _contact_avatar: TextureRect = $ContactAvatar
@onready var _contact_handle: Label = $ContactHandle
@onready var _back: Button = $BackButton
@onready var _close: Button = $CloseButton
@onready var _list_scroll: ScrollContainer = $ListScroll
@onready var _list: VBoxContainer = $ListScroll/List
@onready var _chat_scroll: ScrollContainer = $ChatScroll
@onready var _thread: VBoxContainer = $ChatScroll/Thread
@onready var _decision_panel: PanelContainer = $DecisionPanel
@onready var _decision_title: Label = $DecisionPanel/DecisionContent/DecisionTitle
@onready var _claims: HBoxContainer = $DecisionPanel/DecisionContent/Claims
@onready var _replies: VBoxContainer = $DecisionPanel/DecisionContent/ReplyScroll/Replies

var _chat_revision: int = 0


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
	_title.offset_left = 22.0
	_title.offset_top = 15.0
	_title.offset_right = 144.0
	_title.offset_bottom = 27.0
	_contact_avatar.visible = false
	_contact_handle.visible = false
	_back.visible = false
	_list_scroll.visible = true
	_chat_scroll.visible = false
	_decision_panel.visible = false
	_claims.visible = false
	_replies.visible = false
	_clear(_list)

	for thread in threads:
		var row: Button = thread_row_scene.instantiate()
		_list.add_child(row)
		row.setup(String(thread["item_id"]), String(thread["name"]),
			String(thread["at"]), _one_line(String(thread["preview"])),
			int(thread.get("unread", 0)), _avatar_texture(String(thread.get("avatar", ""))))
		row.row_pressed.connect(func(row_id: String) -> void: thread_opened.emit(row_id))


## A conversa aberta: balões na ordem, o que há para conferir e, quando
## for a sua vez, o que você pode responder.
func show_chat(
	who: String,
	messages: Array,
	replies: Array,
	available: Array,
	claims: Array,
	contradictions: Array,
	first_unread_index: int,
	avatar: Texture2D = null,
	contact_handle: String = ""
) -> void:
	_chat_revision += 1
	_title.text = who
	_title.offset_left = 59.0
	_title.offset_top = 16.0
	_title.offset_right = 144.0
	_title.offset_bottom = 27.0
	_contact_avatar.texture = avatar
	_contact_avatar.visible = avatar != null
	_contact_handle.text = contact_handle
	_contact_handle.visible = not contact_handle.is_empty()
	_back.visible = true
	_list_scroll.visible = false
	_chat_scroll.visible = true
	_chat_scroll.scroll_vertical = 0
	_clear(_thread)
	_clear(_claims)
	_clear(_replies)

	var width: float = _chat_scroll.size.x - 5.0
	# Toda fala mostra a hora em que foi mandada, sem agrupar: é assim que
	# se lê uma conversa fora de ordem depois.
	for message in messages:
		var bubble: Control = bubble_scene.instantiate()
		_thread.add_child(bubble)
		bubble.setup(message.text, message.from_me, message.at, width * 0.94)
	_thread.queue_sort()
	_stack_thread_now()

	for claim in claims:
		var chip: Button = row_scene.instantiate()
		_claims.add_child(chip)
		var caught: bool = contradictions.has(claim.id)
		chip.theme_type_variation = &"DangerButton" if caught else &"PhoneButton"
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
		# A cor comunica o tom da resposta sem rotular uma escolha como
		# moralmente certa: conferir, negociar, confrontar.
		match index:
			0:
				row.theme_type_variation = &"PhoneButton"
			1:
				row.theme_type_variation = &"AmberButton"
			_:
				row.theme_type_variation = &"DangerButton"
		row.setup(str(index), reply.text if not locked else reply.text + " — conferir antes", false)
		row.disabled = locked
		row.clip_text = false
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.custom_minimum_size = Vector2(0, 9)
		row.row_pressed.connect(func(row_id: String) -> void: reply_chosen.emit(int(row_id)))
	_replies.visible = not replies.is_empty()
	_decision_panel.visible = _claims.visible or _replies.visible
	if _claims.visible and _replies.visible:
		_decision_title.text = "CONFERIR / RESPONDER"
	elif _claims.visible:
		_decision_title.text = "CONFERIR"
	else:
		_decision_title.text = "SUA RESPOSTA"
	_position_chat(first_unread_index, _chat_revision)


## Conversa nova abre no começo das não lidas. Sem novidade, conserva o
## comportamento normal de chat e mostra o final. O ScrollContainer limita
## o valor quando há pouco conteúdo, portanto nunca cria vazio artificial.
func _position_chat(first_unread_index: int, revision: int) -> void:
	await get_tree().process_frame
	_stack_thread_now()
	await get_tree().process_frame
	if revision != _chat_revision:
		return
	if first_unread_index >= 0 and first_unread_index < _thread.get_child_count():
		var target: Control = _thread.get_child(first_unread_index)
		_chat_scroll.scroll_vertical = int(target.position.y)
		_chat_scroll.ensure_control_visible(target)
	else:
		_chat_scroll.scroll_vertical = int(_thread.size.y) + 128


## A altura do texto embrulhado muda no nascimento do Label. Antecipar a
## pilha evita que uma rajada apareça por um quadro inteiro na mesma linha
## enquanto o VBox espera sua ordenação diferida.
func _stack_thread_now() -> void:
	var next_y := 0.0
	var separation := float(_thread.get_theme_constant("separation"))
	for bubble: Control in _thread.get_children():
		var minimum := bubble.get_combined_minimum_size()
		bubble.position.y = next_y
		bubble.size.y = maxf(bubble.size.y, minimum.y)
		next_y += bubble.size.y + separation
	_thread.custom_minimum_size.y = maxf(0.0, next_y - separation)


## A prévia é só o começo da última fala.
func _one_line(text: String) -> String:
	var flat := text.replace("
", " ")
	return flat if flat.length() <= 26 else flat.substr(0, 25) + "..."


func showing_chat() -> bool:
	return _chat_scroll.visible


func _avatar_texture(asset_name: String) -> Texture2D:
	if asset_name.is_empty():
		return null
	return load("res://assets/sprites/%s.png" % asset_name)


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
