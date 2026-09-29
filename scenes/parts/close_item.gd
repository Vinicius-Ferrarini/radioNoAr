extends Control

## O close de um item: você pega o celular, ou tira a carta do envelope.
##
## É a mesma cena para os três materiais — o que muda é a superfície, a
## cor do texto e o que existe para conferir (ADR 0010). Um celular tem
## bolha e hora; uma carta tem lacre e assinatura; um comunicado tem
## carimbo e número de protocolo.

signal claim_marked(claim_id: String)
## Índice da resposta escolhida na conversa (ADR 0013).
signal reply_chosen(index: int)
signal suspect_toggled()
signal sibling_selected(item_id: String)
signal close_requested()

@export var row_scene: PackedScene
@export var bubble_scene: PackedScene
@export var phone_surface: Texture2D
@export var letter_surface: Texture2D
@export var official_surface: Texture2D
@export var seal_texture: Texture2D
@export var stamp_texture: Texture2D

## Papel pede tinta escura; tela de celular pede luz. Sem isto o texto
## some no próprio fundo.
const _INK := Color(0.07, 0.06, 0.05)
const _LIGHT := Color(0.91, 0.894, 0.855)

@onready var _surface: NinePatchRect = $Surface
@onready var _avatar_row: HBoxContainer = $AvatarRow
@onready var _sender_name: Label = $SenderName
@onready var _sender_handle: Label = $SenderHandle
@onready var _received_at: Label = $ReceivedAt
@onready var _mark: TextureRect = $Mark
@onready var _bubble: NinePatchRect = $BubbleFrame
@onready var _body: RichTextLabel = $BubbleFrame/BodyScroll/Body
@onready var _thread: VBoxContainer = $BubbleFrame/BodyScroll/Thread
@onready var _scroll: ScrollContainer = $BubbleFrame/BodyScroll
@onready var _replies_box: VBoxContainer = $Replies
@onready var _claims_title: Label = $ClaimsTitle
@onready var _claims_list: HBoxContainer = $ClaimsList
@onready var _suspect: Button = $SuspectButton
@onready var _close_button: Button = $CloseButton


func _ready() -> void:
	_close_button.pressed.connect(func() -> void: close_requested.emit())
	_suspect.pressed.connect(func() -> void: suspect_toggled.emit())


## sibling_chips são os outros itens que chegaram pelo mesmo caminho: as
## conversas do celular, ou a pilha de papel.
func show_item(
	item: BroadcastItem,
	sender: Sender,
	sibling_chips: Array,
	suspicious: bool,
	contradictions: Array,
	scheduled_block: int
) -> void:
	_dress_for(item.channel)
	_fill_header(item, sender, scheduled_block)
	_body.text = item.body
	_body.visible = true
	_thread.visible = false
	_dress_for_conversation(false)
	_suspect.button_pressed = suspicious

	_rebuild_avatar_row(sibling_chips)
	_rebuild_claims(item, contradictions)


## A conversa no lugar do parágrafo: balões na ordem e, quando é a sua
## vez, o que você pode responder no fim da thread — como num celular
## de verdade (ADR 0013). Item sem thread continua em show_item().
func show_thread(messages: Array, replies: Array, available: Array) -> void:
	_body.visible = false
	_thread.visible = true
	_dress_for_conversation(true)
	_clear(_thread)
	_clear(_replies_box)

	var width: float = _scroll.size.x - 4.0
	for message in messages:
		var bubble: Control = bubble_scene.instantiate()
		_thread.add_child(bubble)
		bubble.setup(message.text, message.from_me, width * 0.86)
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_END if message.from_me 			else Control.SIZE_SHRINK_BEGIN

	# As respostas ficam fixas embaixo, fora da rolagem: numa janela de
	# 36 px a opção rolava para fora e nem clique aceitava.
	for index in replies.size():
		var row: Button = row_scene.instantiate()
		_replies_box.add_child(row)
		var reply: ReplyOption = replies[index]
		var locked: bool = not bool(available[index])
		row.setup(str(index), reply.text if not locked else reply.text + " — conferir antes", false)
		row.disabled = locked
		row.clip_text = false
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.custom_minimum_size = Vector2(0, 9)
		row.row_pressed.connect(func(row_id: String) -> void: reply_chosen.emit(int(row_id)))


## Conversa usa o painel todo: a thread sobe para onde ficava o handle e
## a linha de conferir dá lugar às respostas. Item de papel volta ao
## layout de sempre.
func _dress_for_conversation(talking: bool) -> void:
	_sender_handle.visible = not talking
	_claims_title.visible = not talking
	_claims_list.visible = not talking
	_suspect.visible = not talking
	_replies_box.visible = talking
	_bubble.offset_top = 36.0 if talking else 46.0
	_bubble.offset_bottom = 75.0 if talking else 88.0


## A thread cresce para baixo: o jogador tem de ver a última fala, não a
## primeira.
func scroll_to_end() -> void:
	await get_tree().process_frame
	_scroll.scroll_vertical = int(_thread.size.y) + 64


func _dress_for(channel: int) -> void:
	var on_paper: bool = channel != BroadcastItem.Channel.PHONE \
		and channel != BroadcastItem.Channel.CALL

	match channel:
		BroadcastItem.Channel.LETTER:
			_surface.texture = letter_surface
			_mark.texture = seal_texture
		BroadcastItem.Channel.OFFICIAL:
			_surface.texture = official_surface
			_mark.texture = stamp_texture
		_:
			_surface.texture = phone_surface
			_mark.texture = null

	_mark.visible = _mark.texture != null
	_bubble.visible = not on_paper
	_paint_text(_INK if on_paper else _LIGHT)


func _paint_text(color: Color) -> void:
	for label in [_sender_name, _sender_handle, _received_at, _claims_title]:
		label.add_theme_color_override("font_color", color)
	_body.add_theme_color_override("default_color", color)


func _fill_header(item: BroadcastItem, sender: Sender, scheduled_block: int) -> void:
	if sender == null:
		_sender_name.text = item.sender_id
		_sender_handle.text = ""
	else:
		_sender_name.text = sender.display_name
		_sender_handle.text = sender.handle

	_received_at.text = item.received_at
	if scheduled_block != -1:
		_received_at.text = "%s · bloco %d" % [item.received_at, scheduled_block + 1]


## Os chips vem prontos da mesa: {id, name, avatar, current}. O close nao
## abre conteudo por conta propria — quem conhece data/ e o autoload.
func _rebuild_avatar_row(chips: Array) -> void:
	_clear(_avatar_row)
	for chip_data in chips:
		var chip: Button = row_scene.instantiate()
		chip.setup_avatar(chip_data["id"], chip_data["avatar"], chip_data["name"], true)
		chip.toggle_mode = true
		chip.button_pressed = chip_data["current"]
		chip.row_pressed.connect(func(item_id: String) -> void: sibling_selected.emit(item_id))
		_avatar_row.add_child(chip)


func _rebuild_claims(item: BroadcastItem, contradictions: Array) -> void:
	_clear(_claims_list)
	for claim in item.claims:
		var found: bool = contradictions.has(claim.id)
		var row: Button = row_scene.instantiate()
		row.setup(claim.id, ("! " if found else "") + claim.excerpt, false)
		row.tooltip_text = claim.excerpt
		row.custom_minimum_size = Vector2(0, 12)
		row.clip_text = true
		row.row_pressed.connect(func(claim_id: String) -> void: claim_marked.emit(claim_id))
		_claims_list.add_child(row)


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
