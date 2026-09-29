class_name NightCycle
extends RefCounted

## As fases de uma noite. Nao decide conteudo: so move o estado de uma
## fase para a outra e cobra as pre-condicoes de cada passagem.
##
## Ate o M9 nao existe LiveBroadcast: a fase LIVE e uma passagem direta e
## resolve_live() faz tudo menos o que depende do ao vivo (ar morto e
## infracoes). O portao live().is_finished() entra junto com o modulo.

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
