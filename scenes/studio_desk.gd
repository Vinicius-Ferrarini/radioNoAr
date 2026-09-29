extends Control

## A mesa do estúdio, que é a casa do jogo: ela nunca sai da tela. Os
## objetos em cima dela é que abrem (ADR 0010).
##
## Esta cena só escuta sinais do GameState e chama métodos dele. O que
## ela guarda é foco de interface — qual close está aberto, qual item
## está na mão, qual trecho foi marcado. Quem sabe o que foi escalado, o
## que contradiz o quê e quanto vale a cota é a lógica, do outro lado do
## autoload.

## Qual objeto está aberto em cima da mesa.
enum View { DESK, ITEM, NOTEBOOK, BLOCK, IMPROV, MORNING }

const _RESULT_MESSAGES := {
	Validator.Result.CONTRADICTION: "CONTRADIÇÃO: as duas coisas não podem ser verdade.",
	Validator.Result.CONSISTENT: "Confere com o caderno. Não prova que é verdade.",
	Validator.Result.UNRELATED: "Não tem relação com essa linha do caderno.",
}

@onready var _night_label: Label = $Header/NightLabel
@onready var _quota_label: Label = $Header/QuotaLabel
@onready var _audience_label: Label = $Header/AudienceLabel
@onready var _go_on_air: Button = $Header/GoOnAirButton
@onready var _feedback: Label = $Feedback

@onready var _phone: TextureButton = $Phone
@onready var _phone_badge: Label = $Phone/PhoneBadge
@onready var _letters: TextureButton = $LetterStack
@onready var _letter_badge: Label = $LetterStack/LetterBadge
@onready var _notebook_object: TextureButton = $Notebook

@onready var _close_item: Control = $Closes/CloseItem
@onready var _close_notebook: Control = $Closes/CloseNotebook
@onready var _framing_strip: Control = $Closes/FramingStrip
@onready var _improv_strip: Control = $Closes/ImprovStrip
@onready var _close_morning: Control = $Closes/CloseMorning
@onready var _prompter: RichTextLabel = $Studio/Teleprompter/ScriptText
@onready var _line_progress: ProgressBar = $Studio/Teleprompter/LineProgress
@onready var _block_label: Label = $Studio/BlockLabel
@onready var _microphone: TextureButton = $Studio/Microphone
@onready var _on_air_sign: TextureRect = $Studio/OnAirSign

@onready var _blocks: Array[Node] = [
	$Blocks/Block1,
	$Blocks/Block2,
	$Blocks/Block3,
	$Blocks/Block4,
]

## Foco de interface, não estado de jogo.
var _view: View = View.DESK
var _open_item_id: String = ""
var _marked_claim_id: String = ""
var _marked_excerpt: String = ""
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

	GameState.live_block_started.connect(_on_live_block_started)
	GameState.live_events.connect(_on_live_events)

	_microphone.button_down.connect(_on_mic_down)
	_microphone.button_up.connect(_on_mic_up)
	_improv_strip.option_chosen.connect(_on_improv_chosen)
	_close_morning.continue_requested.connect(_on_morning_continue)
	GameState.morning_ready.connect(_on_morning_ready)
	_prompter.meta_clicked.connect(_on_prompter_meta_clicked)

	_phone.pressed.connect(_open_phone)
	_letters.pressed.connect(_open_letters)
	_notebook_object.pressed.connect(_open_notebook)
	_go_on_air.pressed.connect(_on_go_on_air_pressed)

	_close_item.claim_marked.connect(_on_claim_marked)
	_close_item.suspect_toggled.connect(_on_suspect_toggled)
	_close_item.sibling_selected.connect(_open_item)
	_close_item.close_requested.connect(_show_desk)
	_close_notebook.entry_chosen.connect(_on_notebook_entry_chosen)
	_close_notebook.close_requested.connect(_show_desk)
	_framing_strip.framing_chosen.connect(_on_framing_chosen)
	_framing_strip.clear_requested.connect(_on_clear_block)
	_framing_strip.close_requested.connect(_show_desk)

	for block in _blocks:
		block.item_dropped.connect(_on_item_dropped)
		block.block_clicked.connect(_on_block_clicked)

	_show_desk()
	GameState.start_run()


func _unhandled_input(event: InputEvent) -> void:
	# Segurar ESPAÇO é o mesmo que segurar o microfone: quem está no ar
	# com uma mão no dial não larga o botão para clicar.
	if event.is_action_pressed("ui_accept") and _is_live():
		_on_mic_down()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_released("ui_accept") and _is_live():
		_on_mic_up()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel") and _view != View.DESK and _view != View.IMPROV:
		_show_desk()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not _is_live():
		return
	_refresh_live()


func _is_live() -> bool:
	return GameState.current_phase() == NightCycle.Phase.LIVE


# --- sinais do autoload ---

func _on_night_started(night: int, quota: int) -> void:
	_night_label.text = "NOITE %d" % night
	_quota_label.text = "COTA 0/%d" % quota
	_open_item_id = ""
	_clear_mark()
	_selected_block = -1
	_show_desk()
	_feedback.text = "Chegou coisa no celular e na porta."


func _on_inbox_ready(_items: Array) -> void:
	_refresh_badges()


func _on_notebook_updated(_new_entry_ids: Array) -> void:
	if _view == View.NOTEBOOK:
		_refresh_notebook()


func _on_quota_changed(required: int, filled: int) -> void:
	_quota_label.text = "COTA %d/%d" % [filled, required]


func _on_rundown_changed() -> void:
	for i in _blocks.size():
		var item := GameState.block_item(i)
		if item == null:
			_blocks[i].show_empty("%d" % (i + 1))
			continue
		var sender := GameState.sender_of(item.id)
		var who: String = sender.display_name if sender != null else item.headline
		_blocks[i].show_item(who, FramingStrip.label_for(GameState.block_framing(i)))

	_go_on_air.disabled = not GameState.is_rundown_ready()
	_refresh_badges()
	if _view == View.BLOCK:
		_refresh_framing_strip()


func _on_meter_changed(meter_id: String, new_value: int) -> void:
	if meter_id == Meters.AUDIENCE_TRUST:
		_audience_label.text = "OUVINTES %d" % new_value


func _on_phase_changed(phase: int) -> void:
	var before_air: bool = phase == NightCycle.Phase.TRIAGE \
		or phase == NightCycle.Phase.RUNDOWN

	_phone.visible = before_air
	_letters.visible = before_air
	_notebook_object.visible = before_air
	if not before_air:
		_show_desk()

	_microphone.disabled = phase != NightCycle.Phase.LIVE
	_line_progress.visible = phase == NightCycle.Phase.LIVE
	_block_label.visible = phase == NightCycle.Phase.LIVE

	if phase == NightCycle.Phase.LIVE:
		_feedback.text = "Segure o microfone (ou ESPAÇO). Soltar é ar morto."
	else:
		_prompter.text = "O microfone ainda está desligado."
		_block_label.text = ""
		_on_air_sign.modulate = Color(1, 1, 1, 0.35)

	_refresh_audience_label()


func _on_link_evaluated(_item_id: String, _claim_id: String, _entry_id: String, result: int) -> void:
	_feedback.text = _RESULT_MESSAGES.get(result, "")
	if result != Validator.Result.UNRELATED:
		_clear_mark()
	_refresh_notebook()


func _on_suspicion_changed(item_id: String, suspicious: bool) -> void:
	if suspicious:
		_feedback.text = "Anotado como suspeito. Isso não impede de ir ao ar."
	if item_id == _open_item_id and _view == View.ITEM:
		_refresh_item()


# --- abrir os objetos da mesa ---

func _open_phone() -> void:
	var items := _items_on(_phone_channels())
	if items.is_empty():
		_feedback.text = "Nada novo no celular."
		return
	_open_item(items[0].id if _open_item_id.is_empty() else _open_item_id)


func _open_letters() -> void:
	var items := _items_on(_paper_channels())
	if items.is_empty():
		_feedback.text = "Nenhum papel na porta hoje."
		return
	_open_item(items[0].id)


func _open_item(item_id: String) -> void:
	var item := GameState.item_by_id(item_id)
	if item == null:
		return
	_open_item_id = item_id
	_view = View.ITEM
	_refresh_views()
	_refresh_item()


func _open_notebook() -> void:
	_view = View.NOTEBOOK
	_refresh_views()
	_refresh_notebook()


func _show_desk() -> void:
	_view = View.DESK
	_refresh_views()


func _refresh_views() -> void:
	_close_item.visible = _view == View.ITEM
	_close_notebook.visible = _view == View.NOTEBOOK
	_framing_strip.visible = _view == View.BLOCK
	_improv_strip.visible = _view == View.IMPROV
	_close_morning.visible = _view == View.MORNING


# --- interação ---

func _on_claim_marked(claim_id: String) -> void:
	var item := GameState.item_by_id(_open_item_id)
	if item == null:
		return
	for claim in item.claims:
		if claim.id == claim_id:
			_marked_claim_id = claim_id
			_marked_excerpt = claim.excerpt
	_open_notebook()


func _on_notebook_entry_chosen(entry_id: String) -> void:
	if _open_item_id.is_empty() or _marked_claim_id.is_empty():
		_feedback.text = "Abra um item e marque um trecho antes de cruzar."
		return
	GameState.link_claim(_open_item_id, _marked_claim_id, entry_id)


func _on_suspect_toggled() -> void:
	if _open_item_id.is_empty():
		return
	GameState.toggle_suspicion(_open_item_id)


func _on_item_dropped(item_id: String, block_index: int) -> void:
	var already_in := GameState.block_of_item(item_id)
	if already_in != -1:
		GameState.move_block(already_in, block_index)
	else:
		GameState.place_item(item_id, block_index)
	_on_block_clicked(block_index)


func _on_block_clicked(block_index: int) -> void:
	_selected_block = block_index
	_view = View.BLOCK
	_refresh_views()
	_refresh_framing_strip()


func _on_framing_chosen(kind: int) -> void:
	if _selected_block < 0:
		return
	if GameState.set_framing(_selected_block, kind) != ProgramRundown.PlaceResult.OK:
		_feedback.text = "Esse enquadramento não vale para este item."
		return
	_feedback.text = "Bloco %d: %s." % [_selected_block + 1, FramingStrip.label_for(kind)]


func _on_clear_block() -> void:
	if _selected_block < 0:
		return
	GameState.clear_block(_selected_block)


## Para o jogador, triagem e escalação são a mesma mesa: "AO AR" leva ao
## ar de verdade, em vez de trocar de fase sem nada acontecer.
func _on_go_on_air_pressed() -> void:
	if not GameState.is_rundown_ready():
		_feedback.text = "Os quatro blocos precisam de alguém e de um enquadramento."
		return

	while GameState.current_phase() == NightCycle.Phase.TRIAGE \
			or GameState.current_phase() == NightCycle.Phase.RUNDOWN:
		if not GameState.advance_phase():
			return


# --- o ao vivo ---

func _on_live_block_started(position: int, total: int, headline: String) -> void:
	_block_label.text = "BLOCO %d DE %d — %s" % [position + 1, total, headline]
	_show_desk()
	_refresh_live()


func _on_mic_down() -> void:
	if _is_live():
		GameState.set_mic_held(true)


func _on_mic_up() -> void:
	if _is_live():
		GameState.set_mic_held(false)


## As palavras proibidas vão para o roteiro como link invisível: clicar
## troca pelo sinônimo aprovado. Quem tem que lembrar da circular é o
## apresentador, não a interface — por isso nada nelas se destaca.
func _on_prompter_meta_clicked(meta: Variant) -> void:
	if not _is_live():
		return
	if GameState.replace_word(int(meta)):
		_feedback.text = "Trocado a tempo."


func _on_improv_chosen(option_index: int) -> void:
	if GameState.choose_improv(option_index):
		_show_desk()


func _on_live_events(events: Array) -> void:
	for event in events:
		match int(event["kind"]):
			LiveBroadcast.EventKind.DEAD_AIR_STARTED:
				_feedback.text = "AR MORTO. Cada segundo calado custa ouvinte."
			LiveBroadcast.EventKind.DEAD_AIR_ENDED:
				_feedback.text = "Voltou."
			LiveBroadcast.EventKind.FORBIDDEN_WORD_AIRED:
				_feedback.text = "Você disse \"%s\" no ar. Alguém anotou." % event["word"]
			LiveBroadcast.EventKind.IMPROV_REQUESTED:
				_open_improv()
			LiveBroadcast.EventKind.IMPROV_TIMEOUT:
				_feedback.text = "O tempo acabou. Saiu o que estava mais à mão."
				_show_desk()
			LiveBroadcast.EventKind.IMPROV_RESOLVED:
				_show_desk()
			LiveBroadcast.EventKind.BLOCK_FINISHED:
				if GameState.is_live_done():
					_feedback.text = "Fim do programa. O resto chega de manhã."


func _on_morning_ready(report: Dictionary) -> void:
	_view = View.MORNING
	_refresh_views()
	_close_morning.show_report(
		GameState.current_night(),
		report,
		GameState.visible_meters().get(Meters.AUDIENCE_TRUST, 0)
	)
	_close_morning.set_last_night(not GameState.has_next_night())
	_feedback.text = "A conta de ontem chegou."


func _on_morning_continue() -> void:
	GameState.start_next_night()


func _open_improv() -> void:
	_view = View.IMPROV
	_refresh_views()
	_improv_strip.show_improv(GameState.live_improv_prompt(), GameState.live_improv_options())


## O teleprompter mostra a linha anterior apagada, a de agora acesa e a
## próxima esperando — como um teleprompter de verdade.
func _refresh_live() -> void:
	var index := GameState.live_line_index()
	var total := GameState.live_line_count()
	var parts: Array[String] = []

	if index > 0:
		parts.append("[color=#8f8877]%s[/color]" % GameState.live_line_text(index - 1))
	parts.append("[b]%s[/b]" % _with_forbidden_links(index))
	if index + 1 < total:
		parts.append("[color=#8f8877]%s[/color]" % GameState.live_line_text(index + 1))

	_prompter.text = "\n\n".join(parts)
	_line_progress.value = GameState.live_line_progress() * 100.0

	var on_air: bool = GameState.live_state() == LiveBroadcast.State.ON_AIR \
		or GameState.live_state() == LiveBroadcast.State.IMPROV
	_on_air_sign.modulate = Color(1, 1, 1, 1.0 if on_air else 0.3)

	if _view == View.IMPROV:
		_improv_strip.set_seconds_left(GameState.live_improv_seconds_left())


func _with_forbidden_links(index: int) -> String:
	var text := GameState.live_line_text(index)
	for slot_index in GameState.live_forbidden_slots().size():
		var slot := GameState.live_forbidden_slots()[slot_index]
		if slot["line_index"] != index or slot["replaced"] or slot["aired"]:
			continue
		text = text.replace(slot["word"], "[url=%d]%s[/url]" % [slot_index, slot["word"]])
	return text


# --- desenho ---

func _refresh_item() -> void:
	var item := GameState.item_by_id(_open_item_id)
	if item == null:
		return
	_close_item.show_item(
		item,
		GameState.sender_of(item.id),
		_chips_like(item),
		GameState.is_suspicious(item.id),
		GameState.contradictions_for(item.id),
		GameState.block_of_item(item.id)
	)


## Uma foto por conversa, para o jogador trocar de remetente — e para
## arrastar a pessoa direto para um bloco do programa.
func _chips_like(current: BroadcastItem) -> Array[Dictionary]:
	var chips: Array[Dictionary] = []
	for item in _items_on(_channels_like(current.channel)):
		var sender := GameState.sender_of(item.id)
		chips.append({
			"id": item.id,
			"name": sender.display_name if sender != null else item.sender_id,
			"avatar": _avatar_of(sender),
			"current": item.id == current.id,
		})
	return chips


func _avatar_of(sender: Sender) -> Texture2D:
	if sender == null or sender.avatar.is_empty():
		return null
	return load("res://assets/sprites/%s.png" % sender.avatar)


func _refresh_notebook() -> void:
	if _view != View.NOTEBOOK:
		return
	_close_notebook.show_notebook(
		GameState.current_night(),
		GameState.notebook_entries(),
		_marked_excerpt
	)


func _refresh_framing_strip() -> void:
	if _selected_block < 0:
		return
	_framing_strip.show_block(
		_selected_block,
		GameState.block_item(_selected_block),
		GameState.block_framing(_selected_block)
	)


func _refresh_badges() -> void:
	_phone_badge.text = _badge_for(_phone_channels())
	_letter_badge.text = _badge_for(_paper_channels())


## Quantos itens daquele caminho ainda não foram escalados.
func _badge_for(channels: Array[int]) -> String:
	var pending := 0
	for item in _items_on(channels):
		if GameState.block_of_item(item.id) == -1:
			pending += 1
	return "" if pending == 0 else str(pending)


func _refresh_audience_label() -> void:
	var visible_meters := GameState.visible_meters()
	if visible_meters.has(Meters.AUDIENCE_TRUST):
		_audience_label.text = "OUVINTES %d" % visible_meters[Meters.AUDIENCE_TRUST]


func _clear_mark() -> void:
	_marked_claim_id = ""
	_marked_excerpt = ""


func _items_on(channels: Array[int]) -> Array[BroadcastItem]:
	var found: Array[BroadcastItem] = []
	for item in GameState.inbox():
		if channels.has(item.channel):
			found.append(item)
	return found


func _phone_channels() -> Array[int]:
	return [BroadcastItem.Channel.PHONE, BroadcastItem.Channel.CALL] as Array[int]


func _paper_channels() -> Array[int]:
	return [BroadcastItem.Channel.LETTER, BroadcastItem.Channel.OFFICIAL] as Array[int]


func _channels_like(channel: int) -> Array[int]:
	if _phone_channels().has(channel):
		return _phone_channels()
	return _paper_channels()
