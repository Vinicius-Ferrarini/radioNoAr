class_name ConsequenceQueue
extends RefCounted

## O preco de uma noite, cobrado nas manhas seguintes.
##
## A regra que este modulo existe para garantir: nada do que o jogador
## fez hoje pode aparecer hoje.

var _scheduled: Array[Dictionary] = []


## Devolve a noite de vencimento, ou -1 se nao houve o que agendar.
func schedule(effect: ConsequenceEffect, current_night: int) -> int:
	if effect == null:
		return -1

	var due_night: int = current_night + maxi(1, effect.delay_nights)
	_scheduled.append({"effect": effect, "due_night": due_night})
	return due_night


## O que vence ate esta noite, sem tirar da fila.
func peek_due(night: int) -> Array[ConsequenceEffect]:
	var due: Array[ConsequenceEffect] = []
	for entry in _scheduled:
		if entry["due_night"] <= night:
			due.append(entry["effect"])
	return due


## O que vence ate esta noite, tirando da fila. A ordem e a de
## agendamento, nao a de vencimento: a conta mais velha vem primeiro.
func pop_due(night: int) -> Array[ConsequenceEffect]:
	var due: Array[ConsequenceEffect] = []
	var remaining: Array[Dictionary] = []

	for entry in _scheduled:
		if entry["due_night"] <= night:
			due.append(entry["effect"])
		else:
			remaining.append(entry)

	_scheduled = remaining
	return due


func pending_count() -> int:
	return _scheduled.size()


func clear() -> void:
	_scheduled.clear()
