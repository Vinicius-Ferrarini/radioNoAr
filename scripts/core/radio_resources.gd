class_name RadioResources
extends RefCounted

## O que a radio tem para continuar no ar. A logica que move isto e a
## DayPhase (M11); aqui e so o conteiner.

const FUEL := "fuel"
const PARTS := "parts"
const MONEY := "money"
## Alcance do sinal, 0-100. Alcance maior tambem facilita a triangulacao.
const REACH := "reach"

const _INITIAL := {
	FUEL: 40,
	PARTS: 2,
	MONEY: 30,
	REACH: 50,
}

const _REACH_MAX := 100

var _values: Dictionary = {}


func _init() -> void:
	_values = _INITIAL.duplicate()


func get_value(id: String) -> int:
	return _values.get(id, 0)


func has_resource(id: String) -> bool:
	return _values.has(id)


## resource_id -> novo valor, so dos que existem.
func apply(deltas: Dictionary) -> Dictionary:
	var updated: Dictionary = {}
	for id in deltas:
		if not _values.has(id):
			continue
		var value: int = maxi(_values[id] + deltas[id], 0)
		if id == REACH:
			value = mini(value, _REACH_MAX)
		_values[id] = value
		updated[id] = value
	return updated


func snapshot() -> Dictionary:
	return _values.duplicate()


static func all_ids() -> PackedStringArray:
	return PackedStringArray(_INITIAL.keys())
