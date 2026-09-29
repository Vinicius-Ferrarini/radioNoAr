class_name ConsequenceQueue
extends RefCounted

## O preco de uma noite, cobrado de manha.
##
## A unidade da fila e a MANHA, nao a noite: a manha n e a que fecha a
## noite n. Com delay_nights = 1 a conta chega na manha que fecha a
## propria noite — nunca na hora, sempre na manha seguinte, que e o que
## o design pede. Com 2, pula uma manha.

var _scheduled: Array[Dictionary] = []


## Devolve a manha em que a conta chega, ou -1 se nao houve o que
## agendar.
func schedule(effect: ConsequenceEffect, current_night: int) -> int:
	if effect == null:
		return -1

	var due_morning: int = current_night + maxi(1, effect.delay_nights) - 1
	_scheduled.append({"effect": effect, "due_night": due_morning})
	return due_morning


## O que vence ate esta manha, sem tirar da fila.
func peek_due(night: int) -> Array[ConsequenceEffect]:
	var due: Array[ConsequenceEffect] = []
	for entry in _scheduled:
		if entry["due_night"] <= night:
			due.append(entry["effect"])
	return due


## O que vence ate esta manha, tirando da fila. A ordem e a de
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
