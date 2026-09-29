class_name Meters
extends RefCounted

## Os seis eixos da campanha (ADR 0002). Tres deles o jogador nunca ve:
## o regime nao tem medidor, so sinais vagos.

const AUDIENCE_TRUST := "audience_trust"
const STREET_HEAT := "street_heat"
const REGIME_ATTENTION := "regime_attention"
## 0 = povo, 100 = governo. Herdeiro do "Poder" da v0.
const ALIGNMENT := "alignment"
const INTEGRITY := "integrity"
## Contador, nao escala: quantas vezes o apresentador se contradisse.
const INCONSISTENCY := "inconsistency"

const _INITIAL := {
	AUDIENCE_TRUST: 50,
	STREET_HEAT: 30,
	REGIME_ATTENTION: 10,
	ALIGNMENT: 50,
	INTEGRITY: 50,
	INCONSISTENCY: 0,
}

const _HIDDEN := [REGIME_ATTENTION, INTEGRITY, INCONSISTENCY]

## Inconsistencia e a unica sem teto: sempre da para se contradizer mais.
const _MAX := 100

var _values: Dictionary = {}


func _init() -> void:
	_values = _INITIAL.duplicate()


func get_value(id: String) -> int:
	return _values.get(id, 0)


func has_meter(id: String) -> bool:
	return _values.has(id)


## Devolve o novo valor, ou 0 se o id for desconhecido (ver SPEC 4.1:
## quem pega esse erro e o teste de conteudo, nao o tempo de execucao).
func apply(id: String, delta: int) -> int:
	if not _values.has(id):
		return 0

	var updated: int = _values[id] + delta
	if id == INCONSISTENCY:
		_values[id] = maxi(updated, 0)
	else:
		_values[id] = clampi(updated, 0, _MAX)
	return _values[id]


## meter_id -> novo valor, so dos que existem.
func apply_all(deltas: Dictionary) -> Dictionary:
	var updated: Dictionary = {}
	for id in deltas:
		if _values.has(id):
			updated[id] = apply(id, deltas[id])
	return updated


func snapshot() -> Dictionary:
	return _values.duplicate()


static func is_hidden(id: String) -> bool:
	return _HIDDEN.has(id)


static func all_ids() -> PackedStringArray:
	return PackedStringArray(_INITIAL.keys())
