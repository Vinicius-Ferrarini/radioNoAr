class_name NightCycle
extends RefCounted

## As fases de uma noite. Nao decide conteudo: so move o estado de uma
## fase para a outra e cobra as pre-condicoes de cada passagem.
##
## A fase LIVE e uma fila: um LiveBroadcast por bloco que vai ao ar, na
## ordem do programa. So se sai dela quando o ultimo bloco termina.

## O que uma palavra proibida no ar custa em atencao do regime.
const REGIME_ATTENTION_PER_INFRACTION := 8

enum Phase {
	TRIAGE,
	RUNDOWN,
	LIVE,
	MORNING,
	DAY,
	DONE,
}

var _definition: NightDefinition
var _run: RunState
var _validator: Validator
var _rundown: ProgramRundown
var _phase: Phase = Phase.TRIAGE
var _live_resolved := false
var _morning_report: Dictionary = {}

## Um bloco de cada vez vai ao ar. A fila e montada ao entrar em LIVE.
var _live_queue: Array[Dictionary] = []
var _live_position: int = -1
var _live: LiveBroadcast
var _live_results: Array[Dictionary] = []
var _break_used := false
## Uma conversa por item, criada na primeira vez que o jogador abre.
var _conversations: Dictionary = {}
## O relógio da noite: começa às 19:00 e marca a hora de cada mensagem.
var _clock := GameClock.new()
var _last_call: Dictionary = {}


func _init(definition: NightDefinition, run: RunState) -> void:
	_definition = definition
	_run = run
	_run.notebook().add_entries(definition.new_notebook_entries)
	_validator = Validator.new(_run.notebook())
	_rundown = ProgramRundown.new(definition.propaganda_quota, ContentLibrary.order_rules(), _validator)
	_open_the_phone_lines()


func phase() -> Phase:
	return _phase


func inbox() -> Array[BroadcastItem]:
	var available: Array[BroadcastItem] = []
	var flags := _run.flags()
	for item in _definition.inbox:
		if not item.required_flag.is_empty() and not flags.has(item.required_flag):
			continue
		if not item.excluded_flag.is_empty() and flags.has(item.excluded_flag):
			continue
		available.append(item)
	return available


func opening_message() -> String:
	var message := _definition.intro
	if not _definition.opening_flag.is_empty():
		message = (_definition.opening_if_set if _run.flags().has(_definition.opening_flag) else _definition.opening_if_unset) + "\n\n" + message
	return message


func console_snapshot() -> Dictionary:
	if _live == null:
		return {}
	var current := {"caller": _live.caller(), "transcript": _live.call_transcript(),
		"pending": _live.has_pending_call(), "seconds": _live.call_seconds_left(),
		"outcome": _live.call_outcome(), "reaction": _live.reaction()}
	if current["outcome"].is_empty() and not current["pending"] and not _last_call.is_empty():
		current = _last_call.duplicate()
	current["break_seconds"] = _live.break_seconds_left()
	current["break_kind"] = _live.break_kind()
	return current


func title() -> String:
	return _definition.title


func can_take_break() -> bool:
	return _definition.allow_breaks and not _break_used and _phase == Phase.LIVE and _live != null and _live.state() not in [LiveBroadcast.State.READY, LiveBroadcast.State.FINISHED]


func start_break(kind: String) -> bool:
	if not can_take_break() or not _live.start_break(kind):
		return false
	_break_used = true
	return true


func station_mementos() -> Dictionary:
	var flags := _run.flags()
	return {"record": flags.has("celia_music"), "sponsor": flags.has("sponsor_ad"), "bridge": flags.has("rui_aired")}


## Toda conversa da noite nasce com a noite, não quando o jogador abre o
## celular: quem está do outro lado escreve no horário dele. Papel não
## vira conversa — carta e ofício continuam sendo papel.
func _open_the_phone_lines() -> void:
	for item in inbox():
		if item.channel != BroadcastItem.Channel.PHONE:
			continue
		_conversations[item.id] = Conversation.new(
			_thread_of(item), _replies_of(item), _clock)


## Item sem thread escrita ainda é uma conversa: o corpo da mensagem vira
## uma fala e cada enquadramento vira uma resposta. Assim o celular
## inteiro funciona no formato novo e converter o texto passa a ser
## acabamento, não pré-requisito (ADR 0013).
func _thread_of(item: BroadcastItem) -> Array[ChatMessage]:
	if not item.thread.is_empty():
		return item.thread
	var only := ChatMessage.new()
	only.text = item.body
	only.delay_seconds = 0.0
	return [only] as Array[ChatMessage]


func _replies_of(item: BroadcastItem) -> Array[ReplyOption]:
	if not item.replies.is_empty():
		return item.replies
	var built: Array[ReplyOption] = []
	for framing in item.framings:
		if framing == null:
			continue
		var reply := ReplyOption.new()
		reply.id = "%s_%d" % [item.id, framing.kind]
		reply.text = framing.label if not framing.label.is_empty() 			else FramingOption.Kind.keys()[framing.kind]
		reply.framing_kind = framing.kind
		built.append(reply)
	return built


## Nulo para papel: esse continua sendo decidido na régua.
func conversation(item_id: String) -> Conversation:
	return _conversations.get(item_id, null)


func clock() -> GameClock:
	return _clock


## O relógio anda antes das conversas: quem chegar neste quadro leva a
## hora deste quadro.
func tick_time(delta: float) -> void:
	_clock.tick(delta)
	for talk in _conversations.values():
		talk.tick(delta)


func drain_conversation_events() -> Dictionary:
	var by_item: Dictionary = {}
	for item_id in _conversations:
		var events: Array[Dictionary] = _conversations[item_id].drain_events()
		if not events.is_empty():
			by_item[item_id] = events
	return by_item


func item_by_id(item_id: String) -> BroadcastItem:
	for item in _definition.inbox:
		if item.id == item_id:
			return item
	return null


func validator() -> Validator:
	return _validator


func rundown() -> ProgramRundown:
	return _rundown


func can_advance() -> bool:
	match _phase:
		Phase.RUNDOWN:
			return _rundown.is_ready()
		Phase.LIVE:
			return is_live_done()
		Phase.DONE:
			return false
		_:
			return true


func advance() -> Phase:
	if not can_advance():
		return _phase

	match _phase:
		Phase.TRIAGE:
			_phase = Phase.RUNDOWN
		Phase.RUNDOWN:
			_phase = Phase.LIVE
			_open_live()
		Phase.LIVE:
			resolve_live()
			_phase = Phase.MORNING
			_resolve_morning()
		Phase.MORNING:
			_phase = Phase.DAY
		Phase.DAY:
			_phase = Phase.DONE
		Phase.DONE:
			pass

	return _phase


# =====================================================================
# Ao vivo
# =====================================================================

func live() -> LiveBroadcast:
	return _live


func live_block_index() -> int:
	if _live_position < 0 or _live_position >= _live_queue.size():
		return -1
	return _live_queue[_live_position]["block_index"]


func live_block_position() -> int:
	return _live_position


func live_block_count() -> int:
	return _live_queue.size()


func live_item() -> BroadcastItem:
	if _live_position < 0 or _live_position >= _live_queue.size():
		return null
	return _live_queue[_live_position]["item"]


## Todos os blocos ja foram ao ar (ou nao havia nenhum para ir).
func is_live_done() -> bool:
	if _live_queue.is_empty():
		return true
	if _live_position >= _live_queue.size():
		return true
	return _live_position == _live_queue.size() - 1 and _live != null and _live.is_finished()


## Passa para o proximo bloco do programa. false quando o ultimo acabou.
func advance_live_block() -> bool:
	if _live != null and not _live.is_finished():
		return false
	_harvest_live()
	if _live_position + 1 >= _live_queue.size():
		return false
	_start_live_block(_live_position + 1)
	return true


func _open_live() -> void:
	_live_queue.clear()
	_live_results.clear()
	_live_position = -1

	for block_index in ProgramRundown.BLOCK_COUNT:
		var item := _rundown.item_at(block_index)
		var kind := _rundown.framing_at(block_index)
		if item == null or kind == ProgramRundown.NO_FRAMING or kind == FramingOption.Kind.DISCARD:
			continue

		var framing := _find_framing(item, kind)
		if framing == null or framing.script_id.is_empty():
			continue
		var broadcast_script := ContentLibrary.broadcast_script(framing.script_id)
		if broadcast_script == null:
			continue

		_live_queue.append({
			"block_index": block_index,
			"item": item,
			"framing": framing,
			"script": broadcast_script,
		})

	if not _live_queue.is_empty():
		_start_live_block(0)


func _start_live_block(position: int) -> void:
	_live_position = position
	var call: RadioCall = null
	if position == mini(_definition.call_block_position, _live_queue.size() - 1):
		call = _definition.call
	_live = LiveBroadcast.new(_live_queue[position]["script"], _run.rng(), call)


## Guarda o que aquele bloco custou antes de trocar de roteiro.
func _harvest_live() -> void:
	if _live == null or _live_position < 0:
		return
	for result in _live_results:
		if result["position"] == _live_position:
			return
	if not _live.call_outcome().is_empty():
		_last_call = console_snapshot()

	_live_results.append({
		"position": _live_position,
		"item": _live_queue[_live_position]["item"],
		"dead_air_penalty": _live.dead_air_penalty(),
		"infractions": _live.infractions(),
		"chosen_options": _live.chosen_improv_options(),
		"call_outcome": _live.call_outcome(),
		"break_kind": _live.break_kind(),
	})


## Traduz o programa em medidores e em contas para as manhas seguintes.
## Nada do que acontece aqui aparece nesta noite.
func resolve_live() -> void:
	if _live_resolved:
		return
	_live_resolved = true

	var history_before := _run.aired_history()
	var aired: Array[Dictionary] = []

	for block_index in ProgramRundown.BLOCK_COUNT:
		var item := _rundown.item_at(block_index)
		var kind := _rundown.framing_at(block_index)
		if item == null or kind == ProgramRundown.NO_FRAMING:
			continue

		var framing := _find_framing(item, kind)
		if framing == null:
			continue

		var goes_on_air: bool = kind != FramingOption.Kind.DISCARD
		if goes_on_air:
			# So o que foi ao ar mexe em medidor na hora: a audiencia nao
			# reage ao que nao ouviu. O peso de descartar vem pela
			# consequencia, na manha seguinte.
			_run.meters().apply_all(framing.immediate_deltas)
			aired.append({"item": item, "kind": kind})

		# Consequencia vale tambem para o que foi descartado: nao falar e
		# uma resposta, e quem ofereceu o envelope entende como resposta.
		_schedule_consequences(framing.consequence_ids, item, goes_on_air)

	_harvest_live()
	for result in _live_results:
		if _definition.call != null:
			if result["call_outcome"] == "aired":
				_schedule_consequences(_definition.call.aired_consequence_ids, result["item"], true)
			elif result["call_outcome"] == "cut":
				_schedule_consequences(_definition.call.cut_consequence_ids, result["item"], true)
		if result["break_kind"] == "music":
			_schedule_consequences(["p_music"], null, true)
		elif result["break_kind"] == "ad":
			_schedule_consequences(["p_ad"], null, true)
		if result["dead_air_penalty"] != 0:
			_run.meters().apply(Meters.AUDIENCE_TRUST, result["dead_air_penalty"])
		for _infraction in result["infractions"]:
			_run.meters().apply(Meters.REGIME_ATTENTION, REGIME_ATTENTION_PER_INFRACTION)
		for option in result["chosen_options"]:
			_run.meters().apply_all(option.immediate_deltas)
			_schedule_consequences(option.consequence_ids, result["item"], true)

	for rule in _rundown.order_effects():
		_run.meters().apply_all(rule.meter_deltas)
		_schedule_consequences(rule.consequence_ids, null, true)

	_apply_inconsistency(history_before, aired)

	for entry in aired:
		_run.record_aired(entry["item"], entry["kind"])


## O relatorio da manha. Chamar duas vezes nao cobra duas vezes.
func morning_report() -> Dictionary:
	return _morning_report.duplicate(true)


func _resolve_morning() -> void:
	var headlines: Array[String] = []
	if not _definition.baseline_headline.is_empty():
		headlines.append(_definition.baseline_headline)
	var letters: Array[String] = []
	var new_entries: Array[String] = []
	var applied: Dictionary = {}

	for effect in _run.queue().pop_due(_run.current_night()):
		_run.resources().apply(effect.resource_deltas)
		var updated := _run.meters().apply_all(effect.meter_deltas)
		for meter_id in updated:
			applied[meter_id] = updated[meter_id]

		for entry_id in effect.notebook_entry_ids:
			var entry := ContentLibrary.notebook_entry(entry_id)
			if entry != null and _run.notebook().add_entry(entry):
				new_entries.append(entry_id)

		for flag in effect.flags_set:
			_run.set_flag(flag)

		if not effect.morning_headline.is_empty():
			headlines.append(effect.morning_headline)
		if not effect.morning_letter.is_empty():
			letters.append(effect.morning_letter)

	_morning_report = {
		"night": _run.current_night(),
		"headlines": headlines,
		"letters": letters,
		"meter_values": applied,
		"new_entries": new_entries,
	}


func _schedule_consequences(consequence_ids: Array[String], item: BroadcastItem, aired: bool) -> void:
	for consequence_id in consequence_ids:
		var effect := ContentLibrary.consequence(consequence_id)
		if effect == null:
			continue
		if not _condition_holds(effect, item, aired):
			continue
		_run.queue().schedule(effect, _run.current_night())


## A condicao e resolvida agora, na hora de agendar: tudo o que ela
## pergunta ja se sabe nesta noite (SPEC 4.8).
func _condition_holds(effect: ConsequenceEffect, item: BroadcastItem, aired: bool) -> bool:
	match effect.condition:
		ConsequenceEffect.Condition.FRAUD_AIRED:
			return item != null and item.is_fraudulent and aired
		ConsequenceEffect.Condition.FRAUD_CAUGHT:
			return item != null and item.is_fraudulent and _validator.is_suspicious(item.id)
		_:
			return true


## Inflamar hoje o que voce suavizou ontem, para o mesmo remetente, custa
## 1 de inconsistencia — uma vez por noite por remetente.
func _apply_inconsistency(history_before: Array[Dictionary], aired: Array[Dictionary]) -> void:
	var counted: Dictionary = {}
	var earlier := history_before.duplicate()

	for entry in aired:
		var item: BroadcastItem = entry["item"]
		var kind: int = entry["kind"]
		if not _validator.contradictions_for(item.id).is_empty():
			continue

		if not counted.has(item.sender_id):
			for past in earlier:
				if past["sender_id"] == item.sender_id and _are_opposite(past["framing_kind"], kind):
					_run.meters().apply(Meters.INCONSISTENCY, 1)
					counted[item.sender_id] = true
					break

		earlier.append({"sender_id": item.sender_id, "framing_kind": kind})


func _are_opposite(first: int, second: int) -> bool:
	var inflame := FramingOption.Kind.INFLAME
	var soften := FramingOption.Kind.SOFTEN
	return (first == inflame and second == soften) or (first == soften and second == inflame)


func _find_framing(item: BroadcastItem, kind: int) -> FramingOption:
	for framing in item.framings:
		if framing != null and framing.kind == kind:
			return framing
	return null
