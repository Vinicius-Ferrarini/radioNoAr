extends Node

## A ponte entre a lógica e as cenas. Não decide nada: delega para
## RunState/NightCycle e traduz o resultado em sinais.

signal phase_changed(phase: int)
signal night_started(night: int, quota: int)
signal inbox_ready(items: Array)
signal notebook_updated(new_entry_ids: Array)
signal link_evaluated(item_id: String, claim_id: String, entry_id: String, result: int)
signal suspicion_changed(item_id: String, suspicious: bool)
signal rundown_changed()
signal quota_changed(required: int, filled: int)
signal meter_changed(meter_id: String, new_value: int)
signal morning_ready(report: Dictionary)
signal live_block_started(position: int, total: int, headline: String)
signal live_events(events: Array)

var _run: RunState
var _cycle: NightCycle
var _meter_snapshot: Dictionary = {}
## O microfone e do apresentador, nao do bloco: quem esta segurando
## quando um bloco emenda no outro continua segurando.
var _mic_held: bool = false


## O ÚNICO ponto do projeto por onde o tempo entra (ADR 0007). Fora da
## fase LIVE, não faz nada.
func _process(delta: float) -> void:
	if _cycle == null or _cycle.phase() != NightCycle.Phase.LIVE:
		return

	var live := _cycle.live()
	if live == null:
		return

	live.tick(delta)
	var events := live.drain_events()
	if not events.is_empty():
		live_events.emit(events)

	# Bloco terminou e ainda há programa: emenda no próximo.
	if live.is_finished() and not _cycle.is_live_done():
		if _cycle.advance_live_block():
			_cycle.live().set_mic_held(_mic_held)
			_announce_live_block()


# =====================================================================
# v1 — campanha
# =====================================================================

func start_run(seed_value: int = 0) -> void:
	_run = RunState.new(RunState.DEFAULT_TOTAL_NIGHTS, seed_value)
	_open_night()


func has_run() -> bool:
	return _run != null


func current_night() -> int:
	return _run.current_night() if _run != null else 0


func current_phase() -> int:
	return _cycle.phase() if _cycle != null else NightCycle.Phase.DONE


## false quando a fase atual não pode avançar (programa incompleto, por
## exemplo). Quem decide é o NightCycle; aqui só traduzimos.
func advance_phase() -> bool:
	if _cycle == null or not _cycle.can_advance():
		return false

	var before := _cycle.phase()
	var after := _cycle.advance()
	if after == before:
		return false

	_emit_meter_changes()
	phase_changed.emit(after)

	if after == NightCycle.Phase.LIVE:
		_mic_held = false
		_announce_live_block()

	if after == NightCycle.Phase.MORNING:
		morning_ready.emit(_cycle.morning_report())

	return true


# =====================================================================
# v1 — ao vivo
# =====================================================================

func set_mic_held(held: bool) -> void:
	_mic_held = held
	var live := _live()
	if live != null:
		live.set_mic_held(held)


func replace_word(slot_index: int) -> bool:
	var live := _live()
	return live != null and live.replace_word(slot_index)


func choose_improv(option_index: int) -> bool:
	var live := _live()
	return live != null and live.choose_improv(option_index)


func cut_call() -> bool:
	var live := _live()
	return live != null and live.cut_call()


func live_state() -> int:
	var live := _live()
	return live.state() if live != null else LiveBroadcast.State.READY


func live_line_index() -> int:
	var live := _live()
	return live.line_index() if live != null else 0


func live_line_count() -> int:
	var live := _live()
	return live.line_count() if live != null else 0


func live_line_text(index: int) -> String:
	var live := _live()
	return live.line_text(index) if live != null else ""


func live_line_progress() -> float:
	var live := _live()
	return live.line_progress() if live != null else 0.0


func live_forbidden_slots() -> Array[Dictionary]:
	var live := _live()
	return live.forbidden_slots() if live != null else [] as Array[Dictionary]


func live_improv_prompt() -> String:
	var live := _live()
	return live.improv_prompt() if live != null else ""


func live_improv_options() -> Array[ImprovOption]:
	var live := _live()
	return live.improv_options() if live != null else [] as Array[ImprovOption]


func live_improv_seconds_left() -> float:
	var live := _live()
	return live.improv_seconds_left() if live != null else 0.0


func live_dead_air_seconds() -> float:
	var live := _live()
	return live.dead_air_seconds() if live != null else 0.0


func live_block_headline() -> String:
	if _cycle == null:
		return ""
	var item := _cycle.live_item()
	return item.headline if item != null else ""


func live_block_position() -> int:
	return _cycle.live_block_position() if _cycle != null else -1


func live_block_count() -> int:
	return _cycle.live_block_count() if _cycle != null else 0


func is_live_done() -> bool:
	return _cycle == null or _cycle.is_live_done()


func _live() -> LiveBroadcast:
	if _cycle == null or _cycle.phase() != NightCycle.Phase.LIVE:
		return null
	return _cycle.live()


func _announce_live_block() -> void:
	if _cycle == null:
		return
	live_block_started.emit(
		_cycle.live_block_position(),
		_cycle.live_block_count(),
		live_block_headline()
	)


func morning_report() -> Dictionary:
	return _cycle.morning_report() if _cycle != null else {}


## Existe conteudo escrito para a proxima noite? Enquanto a campanha nao
## estiver toda escrita (M13), a fatia vertical termina aqui.
func has_next_night() -> bool:
	if _run == null:
		return false
	if _run.current_night() >= _run.total_nights():
		return false
	return ContentLibrary.night(_run.current_night() + 1) != null


## Fecha a noite e abre a proxima. false quando nao ha proxima.
func start_next_night() -> bool:
	if not has_next_night():
		return false

	while _cycle != null and _cycle.phase() != NightCycle.Phase.DONE:
		if not _cycle.advance():
			break

	_run.advance_night()
	_open_night()
	return true


## Só para reprodutibilidade: confirma que a mesma seed dá a mesma
## campanha, sem expor o RNG para a cena mexer.
func rng_sample() -> int:
	return _run.rng().randi() if _run != null else 0


# =====================================================================
# v1 — triagem
# =====================================================================

func inbox() -> Array[BroadcastItem]:
	return _cycle.inbox() if _cycle != null else [] as Array[BroadcastItem]


func item_by_id(item_id: String) -> BroadcastItem:
	for item in inbox():
		if item.id == item_id:
			return item
	return null


## Quem mandou o item. A cena pergunta aqui em vez de abrir data/ por
## conta propria (ADR 0010).
func sender_of(item_id: String) -> Sender:
	var item := item_by_id(item_id)
	if item == null:
		return null
	return ContentLibrary.sender(item.sender_id)


func notebook_entries() -> Array[NotebookEntry]:
	return _run.notebook().all_entries() if _run != null else [] as Array[NotebookEntry]


func link_claim(item_id: String, claim_id: String, entry_id: String) -> int:
	var item := item_by_id(item_id)
	if item == null or _cycle == null:
		return Validator.Result.UNRELATED

	var result := _cycle.validator().link(item, claim_id, entry_id)
	link_evaluated.emit(item_id, claim_id, entry_id, result)
	return result


func contradictions_for(item_id: String) -> Array[String]:
	if _cycle == null:
		return [] as Array[String]
	return _cycle.validator().contradictions_for(item_id)


func toggle_suspicion(item_id: String) -> void:
	if _cycle == null:
		return
	var value := not _cycle.validator().is_suspicious(item_id)
	_cycle.validator().set_suspicious(item_id, value)
	suspicion_changed.emit(item_id, value)


func is_suspicious(item_id: String) -> bool:
	return _cycle != null and _cycle.validator().is_suspicious(item_id)


# =====================================================================
# v1 — escalação
# =====================================================================

func place_item(item_id: String, block_index: int) -> int:
	var item := item_by_id(item_id)
	if item == null or _cycle == null:
		return ProgramRundown.PlaceResult.INVALID_BLOCK

	var result := _cycle.rundown().place(item, block_index)
	if result == ProgramRundown.PlaceResult.OK:
		_announce_rundown()
	return result


func move_block(from_index: int, to_index: int) -> int:
	if _cycle == null:
		return ProgramRundown.PlaceResult.INVALID_BLOCK
	var result := _cycle.rundown().move(from_index, to_index)
	if result == ProgramRundown.PlaceResult.OK:
		_announce_rundown()
	return result


func clear_block(block_index: int) -> void:
	if _cycle == null:
		return
	_cycle.rundown().clear_block(block_index)
	_announce_rundown()


func set_framing(block_index: int, kind: int) -> int:
	if _cycle == null:
		return ProgramRundown.PlaceResult.INVALID_BLOCK
	var result := _cycle.rundown().set_framing(block_index, kind)
	if result == ProgramRundown.PlaceResult.OK:
		_announce_rundown()
	return result


func block_item(block_index: int) -> BroadcastItem:
	return _cycle.rundown().item_at(block_index) if _cycle != null else null


func block_framing(block_index: int) -> int:
	if _cycle == null:
		return ProgramRundown.NO_FRAMING
	return _cycle.rundown().framing_at(block_index)


func block_of_item(item_id: String) -> int:
	for i in ProgramRundown.BLOCK_COUNT:
		var item := block_item(i)
		if item != null and item.id == item_id:
			return i
	return -1


func is_rundown_ready() -> bool:
	return _cycle != null and _cycle.rundown().is_ready()


func quota_required() -> int:
	return _cycle.rundown().quota_required() if _cycle != null else 0


func quota_filled() -> int:
	return _cycle.rundown().quota_filled() if _cycle != null else 0


# =====================================================================
# v1 — medidores
# =====================================================================

## Só os visíveis. O regime não tem medidor: a UI nunca recebe o valor,
## então não tem como vazar (SPEC secao 5).
## O que ja foi ao ar nesta campanha. A cena usa para mostrar o que o
## apresentador ja disse sobre quem.
func aired_history() -> Array[Dictionary]:
	return _run.aired_history() if _run != null else [] as Array[Dictionary]


func visible_meters() -> Dictionary:
	var visible: Dictionary = {}
	if _run == null:
		return visible
	for meter_id in _run.meters().snapshot():
		if not Meters.is_hidden(meter_id):
			visible[meter_id] = _run.meters().get_value(meter_id)
	return visible


func _open_night() -> void:
	var definition := ContentLibrary.night(_run.current_night())
	if definition == null:
		push_error("noite %d não tem conteúdo em data/nights/" % _run.current_night())
		return

	var known_before := {}
	for entry in _run.notebook().all_entries():
		known_before[entry.id] = true

	_cycle = NightCycle.new(definition, _run)
	_meter_snapshot = _run.meters().snapshot()

	var new_entry_ids: Array[String] = []
	for entry in _run.notebook().all_entries():
		if not known_before.has(entry.id):
			new_entry_ids.append(entry.id)

	night_started.emit(_run.current_night(), _cycle.rundown().quota_required())
	inbox_ready.emit(_cycle.inbox())
	notebook_updated.emit(new_entry_ids)
	_announce_rundown()
	phase_changed.emit(_cycle.phase())


func _announce_rundown() -> void:
	rundown_changed.emit()
	quota_changed.emit(quota_required(), quota_filled())


func _emit_meter_changes() -> void:
	if _run == null:
		return
	var current := _run.meters().snapshot()
	for meter_id in current:
		if Meters.is_hidden(meter_id):
			continue
		if _meter_snapshot.get(meter_id, null) != current[meter_id]:
			meter_changed.emit(meter_id, current[meter_id])
	_meter_snapshot = current
