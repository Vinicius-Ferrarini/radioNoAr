extends Control

## A mesa do estúdio. Só escuta sinais do GameState e chama métodos dele.
## O que esta cena guarda é foco de interface — qual item está aberto,
## qual trecho está marcado, qual aba está visível — nunca estado de
## jogo. Quem sabe o que foi escalado, o que contradiz o quê e quanto
## vale a cota é a lógica, do outro lado do autoload.

@export var row_scene: PackedScene

const _FRAMING_LABELS := {
	FramingOption.Kind.AS_RECEIVED: "Ler como chegou",
	FramingOption.Kind.TRUTH: "Contar a verdade",
	FramingOption.Kind.SOFTEN: "Suavizar",
	FramingOption.Kind.INFLAME: "Inflamar",
	FramingOption.Kind.IRONY: "Ironizar",
	FramingOption.Kind.DISCARD: "Descartar",
}

const _CHANNEL_MARKS := {
	BroadcastItem.Channel.PHONE: "cel",
	BroadcastItem.Channel.LETTER: "carta",
	BroadcastItem.Channel.CALL: "tel",
	BroadcastItem.Channel.OFFICIAL: "of.",
}

const _RESULT_MESSAGES := {
	Validator.Result.CONTRADICTION: "CONTRADIÇÃO: as duas coisas não podem ser verdade.",
	Validator.Result.CONSISTENT: "Falam do mesmo assunto e não se contradizem.",
	Validator.Result.UNRELATED: "Não tem relação com essa linha do caderno.",
}

@onready var _studio: Control = $Studio
@onready var _work_panel: Panel = $WorkPanel
@onready var _night_label: Label = $Header/NightLabel
@onready var _quota_label: Label = $Header/QuotaLabel
@onready var _audience_label: Label = $Header/AudienceLabel
@onready var _go_on_air: Button = $Header/GoOnAirButton

@onready var _inbox_list: VBoxContainer = $WorkPanel/InboxScroll/InboxList
@onready var _tab_item: Button = $WorkPanel/TabItem
@onready var _tab_notebook: Button = $WorkPanel/TabNotebook
@onready var _tab_block: Button = $WorkPanel/TabBlock

@onready var _item_view: Control = $WorkPanel/ItemView
@onready var _headline: Label = $WorkPanel/ItemView/Headline
@onready var _body: RichTextLabel = $WorkPanel/ItemView/BodyScroll/Body
@onready var _claims_list: HBoxContainer = $WorkPanel/ItemView/ClaimsList
@onready var _suspect_button: Button = $WorkPanel/ItemView/SuspectButton

@onready var _notebook_view: ScrollContainer = $WorkPanel/NotebookView
@onready var _notebook_list: VBoxContainer = $WorkPanel/NotebookView/NotebookList

@onready var _block_view: Control = $WorkPanel/BlockView
@onready var _block_title: Label = $WorkPanel/BlockView/BlockTitle
@onready var _framing_list: VBoxContainer = $WorkPanel/BlockView/FramingScroll/FramingList
@onready var _clear_block: Button = $WorkPanel/BlockView/ClearBlockButton

@onready var _feedback: Label = $WorkPanel/Feedback
@onready var _blocks: Array[Node] = [
	$Blocks/Block1,
	$Blocks/Block2,
	$Blocks/Block3,
	$Blocks/Block4,
]

## Foco de interface, não estado de jogo.
var _open_item_id: String = ""
var _marked_claim_id: String = ""
var _selected_block: int = -1


func _ready() -> void:
	GameState.night_started.connect(_on_night_started)
	GameState.inbox_ready.connect(_on_inbox_ready)
	GameState.notebook_updated.connect(_on_notebook_updated)
	GameState.quota_changed.connect(_on_quota_changed)
	GameState.rundown_changed.connect(_on_rundown_changed)
	GameState.meter_changed.connect(_on_meter_changed)
	GameState.phase_changed.connect(_on_phase_changed)
	GameState.link_evaluated.connect(_on_link_evaluated)
	GameState.suspicion_changed.connect(_on_suspicion_changed)

	_go_on_air.pressed.connect(_on_go_on_air_pressed)
	_suspect_button.pressed.connect(_on_suspect_pressed)
	_clear_block.pressed.connect(_on_clear_block_pressed)
	_tab_item.pressed.connect(_show_tab.bind(_tab_item))
	_tab_notebook.pressed.connect(_show_tab.bind(_tab_notebook))
	_tab_block.pressed.connect(_show_tab.bind(_tab_block))

	for block in _blocks:
		block.item_dropped.connect(_on_item_dropped)
		block.block_clicked.connect(_on_block_clicked)

	_show_tab(_tab_item)
	GameState.start_run()


# --- sinais do autoload ---

func _on_night_started(night: int, quota: int) -> void:
	_night_label.text = "NOITE %d" % night
	_quota_label.text = "COTA 0/%d" % quota
	_open_item_id = ""
	_marked_claim_id = ""
	_selected_block = -1
	_refresh_item_view()


func _on_inbox_ready(items: Array) -> void:
	_clear(_inbox_list)
	for item in items:
		var row := _make_row(item.id, _inbox_label(item), true)
		row.row_pressed.connect(_on_inbox_row_pressed)
		_inbox_list.add_child(row)


func _on_notebook_updated(_new_entry_ids: Array) -> void:
	_clear(_notebook_list)
	for entry in GameState.notebook_entries():
		var row := _make_row(entry.id, entry.text, false)
		row.tooltip_text = entry.text
		row.row_pressed.connect(_on_notebook_row_pressed)
		_notebook_list.add_child(row)


func _on_quota_changed(required: int, filled: int) -> void:
	_quota_label.text = "COTA %d/%d" % [filled, required]


func _on_rundown_changed() -> void:
	for i in _blocks.size():
		var item := GameState.block_item(i)
		if item == null:
			_blocks[i].show_empty("%d" % (i + 1))
			continue
		_blocks[i].show_item(item.headline, _framing_name(GameState.block_framing(i)))

	_go_on_air.disabled = not GameState.is_rundown_ready()
	_refresh_block_view()
	_refresh_inbox_marks()


func _on_meter_changed(meter_id: String, new_value: int) -> void:
	if meter_id == Meters.AUDIENCE_TRUST:
		_audience_label.text = "OUVINTES %d" % new_value


func _on_phase_changed(phase: int) -> void:
	var triage_or_rundown: bool = phase == NightCycle.Phase.TRIAGE \
		or phase == NightCycle.Phase.RUNDOWN
	_work_panel.visible = triage_or_rundown
	_studio.modulate.a = 1.0 if not triage_or_rundown else 0.35
	_refresh_audience_label()


func _on_link_evaluated(_item_id: String, _claim_id: String, _entry_id: String, result: int) -> void:
	_feedback.text = _RESULT_MESSAGES.get(result, "")
	_refresh_inbox_marks()


func _on_suspicion_changed(item_id: String, suspicious: bool) -> void:
	if item_id == _open_item_id:
		_suspect_button.button_pressed = suspicious
	_refresh_inbox_marks()


# --- interação ---

func _on_inbox_row_pressed(item_id: String) -> void:
	_open_item_id = item_id
	_marked_claim_id = ""
	_show_tab(_tab_item)
	_refresh_item_view()


func _on_notebook_row_pressed(entry_id: String) -> void:
	if _open_item_id.is_empty() or _marked_claim_id.is_empty():
		_feedback.text = "Marque um trecho do item antes de cruzar."
		return
	GameState.link_claim(_open_item_id, _marked_claim_id, entry_id)


func _on_claim_row_pressed(claim_id: String) -> void:
	_marked_claim_id = claim_id
	_feedback.text = "Trecho marcado. Abra o CADERNO e clique numa linha."
	_show_tab(_tab_notebook)


func _on_suspect_pressed() -> void:
	if _open_item_id.is_empty():
		return
	GameState.toggle_suspicion(_open_item_id)


func _on_item_dropped(item_id: String, block_index: int) -> void:
	var already_in := GameState.block_of_item(item_id)
	if already_in != -1:
		GameState.move_block(already_in, block_index)
	else:
		GameState.place_item(item_id, block_index)
	_selected_block = block_index
	_show_tab(_tab_block)


func _on_block_clicked(block_index: int) -> void:
	_selected_block = block_index
	_show_tab(_tab_block)


func _on_clear_block_pressed() -> void:
	if _selected_block < 0:
		return
	GameState.clear_block(_selected_block)


func _on_framing_row_pressed(framing_id: String) -> void:
	if _selected_block < 0:
		return
	var result := GameState.set_framing(_selected_block, int(framing_id))
	if result != ProgramRundown.PlaceResult.OK:
		_feedback.text = "Esse enquadramento não vale para este item."


## Para o jogador, triagem e escalacao sao a mesma tela: o close cobre as
## duas fases. Entao "AO AR" leva ao ar de verdade, atravessando TRIAGE e
## RUNDOWN de uma vez, em vez de trocar de fase sem nada acontecer.
func _on_go_on_air_pressed() -> void:
	if not GameState.is_rundown_ready():
		_feedback.text = "Os quatro blocos precisam de item e enquadramento."
		return

	while GameState.current_phase() == NightCycle.Phase.TRIAGE 			or GameState.current_phase() == NightCycle.Phase.RUNDOWN:
		if not GameState.advance_phase():
			return


# --- desenho da interface ---

func _show_tab(active: Button) -> void:
	_tab_item.button_pressed = active == _tab_item
	_tab_notebook.button_pressed = active == _tab_notebook
	_tab_block.button_pressed = active == _tab_block

	_item_view.visible = active == _tab_item
	_notebook_view.visible = active == _tab_notebook
	_block_view.visible = active == _tab_block

	if active == _tab_block:
		_refresh_block_view()


func _refresh_item_view() -> void:
	_clear(_claims_list)

	var item := GameState.item_by_id(_open_item_id)
	if item == null:
		_headline.text = "Escolha um item à esquerda"
		_body.text = ""
		_suspect_button.disabled = true
		_suspect_button.button_pressed = false
		return

	_headline.text = item.headline
	_body.text = item.body
	_suspect_button.disabled = false
	_suspect_button.button_pressed = GameState.is_suspicious(item.id)

	var found := GameState.contradictions_for(item.id)
	for claim in item.claims:
		var mark := "!" if found.has(claim.id) else ""
		var row := _make_row(claim.id, mark + claim.excerpt, false)
		row.tooltip_text = claim.excerpt
		row.custom_minimum_size = Vector2(0, 12)
		row.row_pressed.connect(_on_claim_row_pressed)
		_claims_list.add_child(row)


func _refresh_block_view() -> void:
	_clear(_framing_list)

	if _selected_block < 0:
		_block_title.text = "Clique num bloco"
		_clear_block.disabled = true
		return

	var item := GameState.block_item(_selected_block)
	if item == null:
		_block_title.text = "Bloco %d — vazio" % (_selected_block + 1)
		_clear_block.disabled = true
		return

	_block_title.text = "Bloco %d — %s" % [_selected_block + 1, item.headline]
	_clear_block.disabled = false

	var chosen := GameState.block_framing(_selected_block)
	for framing in item.framings:
		var mark := "> " if framing.kind == chosen else ""
		var row := _make_row(str(framing.kind), mark + _framing_name(framing.kind), false)
		row.row_pressed.connect(_on_framing_row_pressed)
		_framing_list.add_child(row)


## Marca na lista o que já foi escalado e o que o jogador achou suspeito.
func _refresh_inbox_marks() -> void:
	for row in _inbox_list.get_children():
		var item := GameState.item_by_id(row.row_id())
		if item == null:
			continue
		row.text = _inbox_label(item)


func _refresh_audience_label() -> void:
	var visible_meters := GameState.visible_meters()
	if visible_meters.has(Meters.AUDIENCE_TRUST):
		_audience_label.text = "OUVINTES %d" % visible_meters[Meters.AUDIENCE_TRUST]


func _inbox_label(item: BroadcastItem) -> String:
	var marks := ""
	if GameState.block_of_item(item.id) != -1:
		marks += "#%d " % (GameState.block_of_item(item.id) + 1)
	if GameState.is_suspicious(item.id):
		marks += "? "
	if GameState.contradictions_for(item.id).size() > 0:
		marks += "! "
	return "%s%s: %s" % [marks, _CHANNEL_MARKS.get(item.channel, ""), item.headline]


func _framing_name(kind: int) -> String:
	return _FRAMING_LABELS.get(kind, "")


func _make_row(row_id: String, row_text: String, draggable: bool) -> Button:
	var row: Button = row_scene.instantiate()
	row.setup(row_id, row_text, draggable)
	return row


## queue_free, nao free: este metodo e chamado de dentro do sinal de uma
## das linhas que ele apaga (escolher enquadramento reconstroi a lista).
func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
