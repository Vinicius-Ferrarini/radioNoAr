extends Node

## A ponte entre a lógica e as cenas. Não decide nada: delega para
## RunState/NightCycle e traduz o resultado em sinais.
##
## Entre o M8 e o M10 este autoload carrega DUAS APIs (ADR 0003): a v1,
## que a mesa do estúdio usa, e a v0, que mantém radio_show.tscn jogável.
## A metade v0 sai no M10, no mesmo commit que apaga Choice/RadioEvent.

# --- v1 ---

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

# --- v0 (sai no M10) ---

signal power_changed(new_value: int)
signal night_advanced(new_night: int)
signal game_ended(ending_id: String)

const TOTAL_NIGHTS := 3
const EVENTS_DIR := "res://data/events/"

var _run: RunState
var _cycle: NightCycle
var _meter_snapshot: Dictionary = {}

var _logic := GameStateLogic.new()
var _events: Array[RadioEvent] = []
var _last_ending_id: String = ""


func _ready() -> void:
	load_events()


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

	if after == NightCycle.Phase.MORNING:
		morning_ready.emit(_cycle.morning_report())

	return true


func morning_report() -> Dictionary:
	return _cycle.morning_report() if _cycle != null else {}


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


# =====================================================================
# v0 — mantido jogável até o M10 (ADR 0003)
# =====================================================================

func load_events() -> void:
	_events.clear()
	var dir := DirAccess.open(EVENTS_DIR)
	if dir == null:
		return

	var file_names: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			file_names.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	file_names.sort()

	for name in file_names:
		var event: RadioEvent = load(EVENTS_DIR + name)
		_events.append(event)


func get_current_event() -> RadioEvent:
	var index := _logic.current_night - 1
	if index < 0 or index >= _events.size():
		return null
	return _events[index]


func apply_choice(choice: Choice) -> void:
	_logic.apply_choice(choice)
	power_changed.emit(_logic.power)
	if _logic.is_finished(TOTAL_NIGHTS):
		_last_ending_id = _logic.resolve_ending()
		game_ended.emit(_last_ending_id)
	else:
		night_advanced.emit(_logic.current_night)


func reset_run() -> void:
	_logic = GameStateLogic.new()
	_last_ending_id = ""


func get_power() -> int:
	return _logic.power


func get_current_night() -> int:
	return _logic.current_night


func get_last_ending_id() -> String:
	return _last_ending_id
