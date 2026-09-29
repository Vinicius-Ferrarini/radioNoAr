class_name GameClock
extends RefCounted

## O relógio da noite. Começa sempre às 19:00 e anda com o tempo injetado,
## nunca com o relógio da máquina (ADR 0007).
##
## Ele é a única fonte de hora do jogo: toda mensagem é marcada por ele no
## instante em que chega. Antes cada fala trazia uma hora escrita à mão no
## conteúdo, e por isso a conversa de um ouvinte podia dizer 19:31 tendo
## chegado antes de outra que dizia 19:12.

const START_HOUR := 19
const _MINUTES_IN_A_DAY := 24 * 60
## Um minuto de programa a cada dois segundos de quem joga: a noite inteira
## cabe numa sessão sem que o relógio fique parado na tela.
const MINUTES_PER_SECOND := 0.5

var _minutes: float = float(START_HOUR * 60)


func tick(delta: float) -> void:
	if delta <= 0.0:
		return
	_minutes += delta * MINUTES_PER_SECOND


## "19:07". Passada a meia-noite, vira para 00:00.
func now() -> String:
	var total := int(_minutes) % _MINUTES_IN_A_DAY
	return "%02d:%02d" % [total / 60, total % 60]


## Minutos corridos desde as 19:00, para quem precisa medir e não mostrar.
func minutes_since_start() -> float:
	return _minutes - float(START_HOUR * 60)
