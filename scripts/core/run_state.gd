class_name RunState
extends RefCounted

## O agregado de uma campanha: o que atravessa as noites.
## Substitui o GameStateLogic da v0 (ADR 0003).

## A campanha vai ate o referendo.
const DEFAULT_TOTAL_NIGHTS := 21

var _total_nights: int
var _current_night: int = 1
var _meters := Meters.new()
var _notebook := Notebook.new()
var _queue := ConsequenceQueue.new()
var _resources := RadioResources.new()
var _rng := RandomNumberGenerator.new()
var _flags: Dictionary = {}
var _aired_history: Array[Dictionary] = []


func _init(total_nights: int = DEFAULT_TOTAL_NIGHTS, seed_value: int = 0) -> void:
	_total_nights = total_nights
	_rng.seed = seed_value


func meters() -> Meters:
	return _meters


func notebook() -> Notebook:
	return _notebook


func queue() -> ConsequenceQueue:
	return _queue


func resources() -> RadioResources:
	return _resources


func rng() -> RandomNumberGenerator:
	return _rng


func current_night() -> int:
	return _current_night


func total_nights() -> int:
	return _total_nights


func advance_night() -> int:
	_current_night += 1
	return _current_night


func is_finished() -> bool:
	return _current_night > _total_nights


func flags() -> Dictionary:
	return _flags.duplicate()


func set_flag(name: String) -> void:
	_flags[name] = true


func has_flag(name: String) -> bool:
	return _flags.has(name)


## Como o NightCycle escreve no historico do que foi ao ar.
func record_aired(item: BroadcastItem, framing_kind: int) -> void:
	if item == null:
		return
	_aired_history.append({
		"night": _current_night,
		"item_id": item.id,
		"sender_id": item.sender_id,
		"item_type": item.type,
		"framing_kind": framing_kind,
	})


func aired_history() -> Array[Dictionary]:
	return _aired_history.duplicate()
