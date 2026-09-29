class_name GameCalendar
extends RefCounted

## A data do jogo. A noite 1 é 15 de julho de 2008 e cada noite seguinte é
## o dia seguinte.
##
## A aritmética é feita à mão de propósito: o relógio global do engine é
## proibido em scripts/core/ (ADR 0007), e depender da máquina para saber
## que dia é na ficção seria trocar uma data determinística por uma que
## muda conforme quem joga.

const START_DAY := 15
const START_MONTH := 7
const START_YEAR := 2008

const _MONTH_DAYS := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]


## "15/07/2008" para a noite 1. Noite antes da primeira não inventa data.
static func date_of(night: int) -> String:
	var day := START_DAY
	var month := START_MONTH
	var year := START_YEAR

	for i in maxi(night - 1, 0):
		day += 1
		if day > _days_in(month, year):
			day = 1
			month += 1
			if month > 12:
				month = 1
				year += 1

	return "%02d/%02d/%04d" % [day, month, year]


static func _days_in(month: int, year: int) -> int:
	if month == 2 and _is_leap(year):
		return 29
	return _MONTH_DAYS[month - 1]


static func _is_leap(year: int) -> bool:
	if year % 400 == 0:
		return true
	if year % 100 == 0:
		return false
	return year % 4 == 0
