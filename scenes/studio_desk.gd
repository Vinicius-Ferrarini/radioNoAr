extends Control

## Vazio usa a campanha padrão do autoload.
@export_dir var campaign_directory: String = ""

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

## Por que o item nao entrou no bloco. Sem isto a recusa e muda e o
## jogador acha que colocou.
const _PLACE_MESSAGES := {
	ProgramRundown.PlaceResult.INVALID_BLOCK: "Esse bloco não existe.",
	ProgramRundown.PlaceResult.BLOCK_TAKEN: "Esse bloco já tem alguém: tire antes de trocar.",
	ProgramRundown.PlaceResult.ITEM_ALREADY_PLACED: "Essa pessoa já está em outro bloco.",
	ProgramRundown.PlaceResult.FRAMING_NOT_ALLOWED: "A ordem do programa não permite esse item aqui.",
}

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
@onready var _enter_air: Button = $EnterAirButton
@onready var _call_panel: Control = $CallPanel
@onready var _call_text: Label = $CallPanel/Transcript
@onready var _call_status: Label = $CallPanel/Status
@onready var _call_progress: ProgressBar = $CallPanel/Delay
@onready var _cut_button: Button = $CallPanel/Cut
@onready var _music: Button = $LiveControls/Music
@onready var _ad: Button = $LiveControls/Ad
@onready var _mic_switch: Button = $LiveControls/Mic
@onready var _desk_lamp: TextureRect = $Studio/DeskLamp
@onready var _ambience: AudioStreamPlayer = $Ambience
@onready var _static: AudioStreamPlayer = $Static
@onready var _sfx: AudioStreamPlayer = $Sfx
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

const _SWITCH = preload("res://assets/audio/switch.wav")
const _RING = preload("res://assets/audio/phone_ring.wav")
const _CUT = preload("res://assets/audio/line_cut.wav")
const _JINGLE = preload("res://assets/audio/station_jingle.wav")
const _WALTZ = preload("res://assets/audio/neighborhood_waltz.wav")
const _AD = preload("res://assets/audio/workshop_ad.wav")
## Leitos contínuos: o estúdio zumbindo e o transmissor chiando. Não são
## efeitos, são o fundo que faz o silêncio virar som (ADR 0012).
const _ROOM_TONE = preload("res://assets/audio/room_tone.wav")
const _STATIC = preload("res://assets/audio/radio_static.wav")

## Mixagem da estática por estado da mesa, em dB.
const _STATIC_OFF_AIR := -26.0
const _STATIC_ON_AIR := -34.0
const _STATIC_DEAD_AIR := -11.0
const _STATIC_BREAK := -42.0

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


## Relógio só de apresentação: nada de estado de jogo aqui, só o que a
## mesa precisa para respirar (luz, letreiro, telefone tremendo).
var _clock: float = 0.0
var _phone_home: Vector2 = Vector2.ZERO


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

	_enter_air.pressed.connect(_on_enter_air_pressed)
	_microphone.pressed.connect(_toggle_mic)
	_mic_switch.pressed.connect(_toggle_mic)
	_cut_button.pressed.connect(_cut_call)
	_music.pressed.connect(func() -> void: GameState.start_break("music"))
	_ad.pressed.connect(func() -> void: GameState.start_break("ad"))
	$Briefing/Start.pressed.connect(func() -> void: $Briefing.hide())
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

	_phone_home = _phone.position
	_ambience.stream = _ROOM_TONE
	_static.stream = _STATIC
	_ambience.play()
	_static.play()

	_show_desk()
	GameState.start_run(0, campaign_directory)


func _input(event: InputEvent) -> void:
	# Segurar ESPAÇO é o mesmo que segurar o microfone: quem está no ar
	# com uma mão no dial não larga o botão para clicar.
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE and _is_live():
		_toggle_mic()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_C and _is_live():
		_cut_call()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel") and _view != View.DESK and _view != View.IMPROV:
		_show_desk()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_clock += delta
	_breathe(delta)
	if not _is_live():
		return
	_refresh_live()


## A mesa nunca fica parada nem muda: a lâmpada oscila, o letreiro pulsa
## quando o microfone está aberto, o telefone treme enquanto a ligação
## espera no atraso, e a estática sobe no ar morto. Só apresentação —
## nada aqui decide nada.
func _breathe(delta: float) -> void:
	_desk_lamp.modulate.a = 0.93 + sin(_clock * 2.3) * 0.04 + sin(_clock * 9.7) * 0.03

	var live := _is_live()
	# O letreiro conta o que sai pela antena, nao a posicao da chave: em
	# ar morto ele apaga junto com a voz.
	var state: int = GameState.live_state() if live else -1
	var airing := [LiveBroadcast.State.ON_AIR, LiveBroadcast.State.IMPROV]
	var on_air: bool = state in airing
	if live:
		var pulse: float = sin(_clock * 5.0) * 0.1
		_on_air_sign.modulate.a = (0.9 + pulse) if on_air else (0.34 + pulse * 0.3)
	else:
		_on_air_sign.modulate.a = 0.3

	var console := GameState.live_console() if live else {}
	var ringing: bool = console.get("pending", false)
	_phone.position = _phone_home + (Vector2(sin(_clock * 34.0) * 1.0, 0.0) if ringing else Vector2.ZERO)
	_phone.modulate.a = (0.75 + absf(sin(_clock * 6.0)) * 0.25) if ringing else 1.0

	var target := _STATIC_OFF_AIR
	if console.get("break_seconds", 0.0) > 0.0:
		target = _STATIC_BREAK
	elif live:
		target = _STATIC_ON_AIR if on_air else _STATIC_DEAD_AIR
	_static.volume_db = move_toward(_static.volume_db, target, 26.0 * delta)


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
	_music_player.stop()
	_sfx.stop()
	$Briefing/Title.text = "%02d / %s" % [night, GameState.night_title()]
	$Briefing/Body.text = GameState.opening_message()
	$Briefing/Reserve.text = "CAIXA $%d / 1 reserva: música ou anúncio" % GameState.station_money()
	$Briefing.visible = not GameState.opening_message().is_empty()
	var mementos := GameState.station_mementos()
	$Studio/GiftRecord.visible = mementos.get("record", false)
	$Studio/Sponsor.visible = mementos.get("sponsor", false)
	$Studio/BridgeNote.visible = mementos.get("bridge", false)
	$Header/AudienceLabel.tooltip_text = "Caixa da rádio: $%d" % GameState.station_money()


func _on_inbox_ready(_items: Array) -> void:
	_refresh_badges()


func _on_notebook_updated(_new_entry_ids: Array) -> void:
	if _view == View.NOTEBOOK:
		_refresh_notebook()


func _on_quota_changed(required: int, filled: int) -> void:
	_quota_label.text = "PROGRAMA LIVRE" if required == 0 else "COTA %d/%d" % [filled, required]
	_blocks[0].texture = preload("res://assets/sprites/block_slot.png") if required == 0 else preload("res://assets/sprites/block_slot_quota.png")


func _on_rundown_changed() -> void:
	for i in _blocks.size():
		var item := GameState.block_item(i)
		if item == null:
			_blocks[i].show_empty("%d" % (i + 1))
			continue
		var sender := GameState.sender_of(item.id)
		var who: String = sender.display_name if sender != null else item.headline
		var kind := GameState.block_framing(i)
		if kind == ProgramRundown.NO_FRAMING:
			# Sem isto um bloco sem enquadramento fica igual a um pronto, e
			# o unico caminho adiante (AO AR) esta escuro e calado.
			_blocks[i].show_item(who, "escolher")
			continue
		var label := GameState.framing_label(item, kind)
		_blocks[i].show_item(who, label if not label.is_empty() else FramingStrip.label_for(kind))

	_go_on_air.disabled = not GameState.is_rundown_ready()
	if not _is_live() and not GameState.is_rundown_ready():
		_feedback.text = _pending_hint()
	_refresh_badges()
	if _view == View.BLOCK:
		_refresh_framing_strip()


## O proximo passo, um por vez: o rodape da mesa e a unica linha que o
## jogador le sem procurar. Dizer "falta algo" nao serve — tem que dizer
## qual bloco e o que fazer nele.
func _pending_hint() -> String:
	# Bloco por bloco, e nao todos os vazios primeiro: quem acabou de
	# soltar alguem num bloco precisa ouvir sobre o enquadramento dele,
	# que e a regua aberta na frente do jogador naquele instante.
	for i in _blocks.size():
		if GameState.block_item(i) == null:
			return "Bloco %d vazio: arraste alguém do celular ou das cartas." % (i + 1)
		if GameState.block_framing(i) == ProgramRundown.NO_FRAMING:
			return "Bloco %d: escolha na régua como esse item vai ao ar." % (i + 1)
	return ""


func _on_meter_changed(meter_id: String, new_value: int) -> void:
	if meter_id == Meters.AUDIENCE_TRUST:
		_audience_label.text = "OUVINTES %d" % new_value


func _on_phase_changed(phase: int) -> void:
	var before_air: bool = phase == NightCycle.Phase.TRIAGE \
		or phase == NightCycle.Phase.RUNDOWN

	var live_now := phase == NightCycle.Phase.LIVE
	_phone.visible = before_air or live_now
	_letters.visible = before_air or live_now
	_notebook_object.visible = before_air or live_now
	$Blocks.visible = before_air
	$LiveControls.visible = live_now
	_call_panel.visible = live_now
	$Studio/Turntable.visible = not live_now
	$Studio/Teleprompter.position = Vector2(76, 34) if live_now else Vector2(112, 36)
	$Studio/Teleprompter.size = Vector2(232, 46) if live_now else Vector2(128, 60)
	$Studio/Teleprompter/LineProgress.position.y = 39 if live_now else 53
	$Studio/Teleprompter/LineProgress.size.x = 218 if live_now else 114
	if not before_air:
		_show_desk()

	_microphone.disabled = phase != NightCycle.Phase.LIVE
	_line_progress.visible = phase == NightCycle.Phase.LIVE
	_block_label.visible = phase == NightCycle.Phase.LIVE

	if phase == NightCycle.Phase.LIVE:
		_feedback.text = "ESPAÇO: microfone  /  C: cortar ligação"
		_play_sound(_JINGLE)
		_go_on_air.disabled = true
	else:
		_go_on_air.text = "AO AR"
		_go_on_air.disabled = not before_air or not GameState.is_rundown_ready()
		_prompter.text = "O microfone ainda está desligado."
		_block_label.text = ""

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
	if _is_live():
		return
	var already_in := GameState.block_of_item(item_id)
	var result: int = ProgramRundown.PlaceResult.OK
	if already_in != -1:
		result = GameState.move_block(already_in, block_index)
	else:
		result = GameState.place_item(item_id, block_index)
	if result != ProgramRundown.PlaceResult.OK:
		_feedback.text = _PLACE_MESSAGES.get(result, "Esse item não pode ir nesse bloco.")
		return
	_on_block_clicked(block_index)


func _on_block_clicked(block_index: int) -> void:
	if _is_live():
		return
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
	var label := GameState.framing_label(GameState.block_item(_selected_block), kind)
	_feedback.text = "Bloco %d: %s." % [_selected_block + 1, label if not label.is_empty() else FramingStrip.label_for(kind)]


func _on_clear_block() -> void:
	if _selected_block < 0:
		return
	GameState.clear_block(_selected_block)


## Para o jogador, triagem e escalação são a mesma mesa: "AO AR" leva ao
## ar de verdade, em vez de trocar de fase sem nada acontecer.
func _on_go_on_air_pressed() -> void:
	if _is_live():
		if GameState.is_live_done():
			GameState.advance_phase()
		return
	$Briefing.hide()
	if not GameState.is_rundown_ready():
		_feedback.text = "Os quatro blocos precisam de alguém e de um enquadramento."
		return

	while GameState.current_phase() == NightCycle.Phase.TRIAGE \
			or GameState.current_phase() == NightCycle.Phase.RUNDOWN:
		if not GameState.advance_phase():
			return


## O botao dedicado a entrar no ar. Nunca fica desabilitado e nunca fica
## calado: quando nao da para subir, ele diz por que e abre exatamente o
## que falta resolver. Um botao desabilitado nao ensina nada.
func _on_enter_air_pressed() -> void:
	match GameState.current_phase():
		NightCycle.Phase.LIVE:
			if GameState.is_live_done():
				_feedback.text = "O programa terminou. Use MANHÃ para ver a repercussão."
			else:
				_feedback.text = "Você já está no ar. ESPAÇO liga o microfone, C corta a ligação."
			return
		NightCycle.Phase.MORNING, NightCycle.Phase.DONE:
			_feedback.text = "A noite já acabou. Continue pelo jornal da manhã."
			return

	$Briefing.hide()
	if GameState.is_rundown_ready():
		_on_go_on_air_pressed()
		return

	# Nao basta dizer o que falta: levar o jogador ate lá.
	_feedback.text = _pending_hint()
	for i in _blocks.size():
		if GameState.block_item(i) == null:
			_open_phone()
			return
		if GameState.block_framing(i) == ProgramRundown.NO_FRAMING:
			_on_block_clicked(i)
			return


# --- o ao vivo ---

func _on_live_block_started(position: int, total: int, headline: String) -> void:
	_block_label.text = "BLOCO %d DE %d" % [position + 1, total]
	_show_desk()
	_refresh_live()


## Abrir e fechar o microfone continuam sendo duas entradas separadas: a
## chave da mesa apenas escolhe qual delas chamar. Assim o caminho que o
## jogador percorre e o que os testes exercitam sao o mesmo.
func _on_mic_down() -> void:
	if _is_live():
		GameState.set_mic_held(true)


func _on_mic_up() -> void:
	if _is_live():
		GameState.set_mic_held(false)


func _toggle_mic() -> void:
	if not _is_live():
		return
	if GameState.microphone_open():
		_on_mic_up()
	else:
		_on_mic_down()
	_play_sound(_SWITCH)


func _cut_call() -> void:
	if GameState.cut_call():
		_play_sound(_CUT)
		_refresh_live()


func _play_sound(stream: AudioStream) -> void:
	_sfx.stream = stream
	_sfx.play()


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
			LiveBroadcast.EventKind.CALL_TRANSCRIPT:
				_play_sound(_RING)
			LiveBroadcast.EventKind.CALL_CUT, LiveBroadcast.EventKind.CALL_AIRED:
				_feedback.text = GameState.live_console().get("reaction", "")
			LiveBroadcast.EventKind.BREAK_STARTED:
				_music_player.stream = _WALTZ if event["break_kind"] == "music" else _AD
				_music_player.play()
			LiveBroadcast.EventKind.BREAK_ENDED:
				_music_player.stop()
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
	if GameState.has_next_night():
		GameState.start_next_night()
	else:
		GameState.restart_run()


func _open_improv() -> void:
	_view = View.IMPROV
	_refresh_views()
	_improv_strip.show_improv(GameState.live_improv_prompt(), GameState.live_improv_options())


## O teleprompter mostra a linha anterior apagada, a de agora acesa e a
## próxima esperando — como um teleprompter de verdade.
func _refresh_live() -> void:
	var index := GameState.live_line_index()
	var parts: Array[String] = []

	parts.append("[b]%s[/b]" % _with_forbidden_links(index))

	_prompter.text = "\n\n".join(parts)
	_line_progress.value = GameState.live_line_progress() * 100.0


	if _view == View.IMPROV:
		_improv_strip.set_seconds_left(GameState.live_improv_seconds_left())
	_refresh_console()


func _refresh_console() -> void:
	var console := GameState.live_console()
	var pending: bool = console.get("pending", false)
	var outcome: String = console.get("outcome", "")
	var seconds: float = console.get("seconds", 0.0)
	var break_left: float = console.get("break_seconds", 0.0)
	_cut_button.disabled = not pending
	_call_progress.value = seconds / LiveBroadcast.CALL_DELAY_SECONDS * 100.0
	_call_progress.visible = pending
	_call_text.text = console.get("transcript", "") if pending else console.get("reaction", "")
	if pending:
		_call_status.text = "PRÉVIA / %s / %.1fs" % [console.get("caller", ""), seconds]
	elif outcome == "aired":
		_call_status.text = "TRANSMITIDO / " + String(console.get("caller", ""))
	elif outcome == "cut":
		_call_status.text = "CORTADO / NÃO TRANSMITIDO"
	else:
		_call_status.text = "LINHA LIVRE / retorno de 7 segundos"
		_call_text.text = "Quem ligar aparece aqui antes de ir ao ar. Você pode cortar com C."
	if break_left > 0.0:
		_call_status.text = "INTERVALO / PRÉVIA EM ESPERA / %.1fs" % break_left
	_music.disabled = not GameState.can_take_break()
	_ad.disabled = _music.disabled
	_mic_switch.text = "MIC LIGADO" if GameState.microphone_open() else "MIC DESLIGADO"
	if GameState.is_live_done():
		_go_on_air.text = "MANHÃ"
		_go_on_air.disabled = false
		_music_player.stop()


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
