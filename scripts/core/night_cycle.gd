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


func _init(definition: NightDefinition, run: RunState) -> void:
	_definition = definition
	_run = run
	_run.notebook().add_entries(definition.new_notebook_entries)
	_validator = Validator.new(_run.notebook())
	_rundown = ProgramRundown.new(definition.propaganda_quota, ContentLibrary.order_rules())


func phase() -> Phase:
	return _phase


func inbox() -> Array[BroadcastItem]:
	return _definition.inbox


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
	_live = LiveBroadcast.new(_live_queue[position]["script"], _run.rng())


## Guarda o que aquele bloco custou antes de trocar de roteiro.
func _harvest_live() -> void:
	if _live == null or _live_position < 0:
		return
	for result in _live_results:
		if result["position"] == _live_position:
			return

	_live_results.append({
		"position": _live_position,
		"item": _live_queue[_live_position]["item"],
		"dead_air_penalty": _live.dead_air_penalty(),
		"infractions": _live.infractions(),
		"chosen_options": _live.chosen_improv_options(),
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
	var letters: Array[String] = []
	var new_entries: Array[String] = []
	var applied: Dictionary = {}

	for effect in _run.queue().pop_due(_run.current_night()):
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
