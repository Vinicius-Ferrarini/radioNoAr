class_name LiveBroadcast
extends RefCounted

## A máquina de estados do ao vivo: teleprompter, ar morto, palavras
## proibidas, improviso e a ligação com delay.
##
## Não conhece Node, não olha relógio e não mexe em medidor. O tempo
## entra por tick(delta) e as ocorrências saem por drain_events() — é o
## que permite testar a mecânica mais complexa do jogo em milissegundos
## e sempre com o mesmo resultado (ADR 0007).
##
## Quem aplica os deltas e as infrações é o NightCycle, depois.

enum State {
	## O microfone está na mesa. Nada acontece.
	READY,
	ON_AIR,
	## Microfone solto no meio do programa: o pior som do rádio.
	DEAD_AIR,
	## O roteiro parou e o relógio corre.
	IMPROV,
	FINISHED,
}

enum EventKind {
	LINE_ADVANCED,
	DEAD_AIR_STARTED,
	DEAD_AIR_ENDED,
	FORBIDDEN_WORD_AIRED,
	WORD_REPLACED,
	IMPROV_REQUESTED,
	IMPROV_RESOLVED,
	IMPROV_TIMEOUT,
	## Tocou com a linha ocupada: entrou na fila.
	CALL_WAITING,
	CALL_TRANSCRIPT,
	CALL_AIRED,
	CALL_CUT,
	BLOCK_FINISHED,
	BREAK_STARTED,
	BREAK_ENDED,
}

## Ouvintes perdidos por segundo de silêncio.
const DEAD_AIR_TRUST_PER_SECOND := 2.0
## O atraso legal entre a transcrição e o ar. É a sua única defesa.
const CALL_DELAY_SECONDS := 7.0

var _script: BroadcastScript
var _rng: RandomNumberGenerator

var _state: State = State.READY
## Para onde voltar quando o microfone for retomado.
var _state_before_silence: State = State.ON_AIR

var _line_index: int = 0
var _line_elapsed: float = 0.0
var _dead_air: float = 0.0

## Um registro por slot, achatado: {line_index, slot_index, word,
## approved_synonym, char_start, replaced, aired}
var _slots: Array[Dictionary] = []
var _infractions: Array[String] = []

var _improv_left: float = 0.0
var _chosen_improvs: Array[String] = []
var _chosen_options: Array[ImprovOption] = []

## A linha atende uma por vez: as agendadas esperam o gatilho, as
## acionadas esperam a linha vagar, e só uma fica na prévia (ADR 0013).
var _scheduled: Array[RadioCall] = []
var _waiting: Array[RadioCall] = []
var _on_line: RadioCall = null
var _call_left: float = 0.0
var _results: Array[Dictionary] = []
var _elapsed := 0.0
var _call_outcome := ""
var _reaction := ""
var _break_kind := ""
var _break_left := 0.0

var _events: Array[Dictionary] = []


func _init(broadcast_script: BroadcastScript, rng: RandomNumberGenerator,
		calls: Array[RadioCall] = [] as Array[RadioCall]) -> void:
	_script = broadcast_script
	_rng = rng
	for call in calls:
		if call != null:
			_scheduled.append(call)
	_flatten_slots()


# =====================================================================
# Entradas do jogador
# =====================================================================

func set_mic_held(held: bool) -> void:
	if _state == State.FINISHED:
		return

	if held:
		if _state == State.DEAD_AIR:
			_state = _state_before_silence
			_push(EventKind.DEAD_AIR_ENDED, {"seconds": _dead_air})
		elif _state == State.READY:
			_enter_line(0)
		return

	if _state == State.READY or _state == State.DEAD_AIR:
		return

	_state_before_silence = _state
	_state = State.DEAD_AIR
	_push(EventKind.DEAD_AIR_STARTED, {})


## Troca a palavra proibida pelo sinônimo aprovado, enquanto a linha dela
## ainda não foi ao ar.
func replace_word(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _slots.size():
		return false

	var slot := _slots[slot_index]
	if slot["replaced"] or slot["aired"]:
		return false

	slot["replaced"] = true
	_push(EventKind.WORD_REPLACED, {
		"slot_index": slot_index,
		"word": slot["word"],
		"approved_synonym": slot["approved_synonym"],
	})
	return true


func choose_improv(option_index: int) -> bool:
	var point := _current_improv()
	if point == null or not _improv_running():
		return false
	if option_index < 0 or option_index >= point.options.size():
		return false

	_take_improv(point, option_index, EventKind.IMPROV_RESOLVED)
	return true


## Corta quem está na prévia. A linha vaga na hora e quem esperava entra.
func cut_call() -> bool:
	if _on_line == null:
		return false

	_resolve_call("cut", _on_line.cut_reaction, EventKind.CALL_CUT)
	_take_the_line()
	return true


## Fecha a ligação da prévia e guarda o que aconteceu com ela.
func _resolve_call(outcome: String, reaction: String, kind: EventKind) -> void:
	_results.append({"call": _on_line, "outcome": outcome})
	_call_outcome = outcome
	_reaction = reaction
	_push(kind, {"transcript": _on_line.transcript, "caller": _on_line.caller})
	_on_line = null
	_call_left = 0.0


## Passa a linha para quem está esperando, se houver.
func _take_the_line() -> void:
	if _on_line != null or _waiting.is_empty():
		return
	_on_line = _waiting.pop_front()
	_call_left = CALL_DELAY_SECONDS
	_push(EventKind.CALL_TRANSCRIPT, {
		"transcript": _on_line.transcript,
		"caller": _on_line.caller,
		"delay": CALL_DELAY_SECONDS,
	})


# =====================================================================
# O tempo
# =====================================================================

func tick(delta: float) -> void:
	if delta <= 0.0 or _state == State.READY or _state == State.FINISHED:
		return
	if _break_left > 0.0:
		var consumed := minf(delta, _break_left)
		_break_left -= consumed
		delta -= consumed
		if _break_left <= 0.0:
			_push(EventKind.BREAK_ENDED, {})
		if delta <= 0.0:
			return

	# Quem chegou neste quadro não gasta a prévia com o tempo de antes de
	# chegar: o relógio da prévia só conta o que sobrou depois do gatilho.
	var call_delta := delta
	var earliest := _seconds_until_next_trigger()
	_elapsed += delta
	if _ring_whoever_arrived():
		call_delta = maxf(delta - earliest, 0.0)
	_take_the_line()
	_tick_call(call_delta)

	# O relógio do improviso corre mesmo no silêncio: ficar calado não é
	# uma saída (regra 7).
	if _improv_running():
		_tick_improv(delta)

	if _state != State.ON_AIR:
		if _state == State.DEAD_AIR:
			_dead_air += delta
		return

	_tick_script(delta)


## Quanto falta para o próximo gatilho, para não cobrar da prévia o tempo
## anterior à chegada.
func _seconds_until_next_trigger() -> float:
	var soonest := INF
	for call in _scheduled:
		soonest = minf(soonest, maxf(call.trigger_seconds - _elapsed, 0.0))
	return 0.0 if soonest == INF else soonest


## Toca o telefone de quem venceu o gatilho. Quem chega com a linha
## ocupada vai para a fila e avisa que tocou.
func _ring_whoever_arrived() -> bool:
	var rang := false
	var still: Array[RadioCall] = []
	for call in _scheduled:
		if _elapsed < call.trigger_seconds:
			still.append(call)
			continue
		_waiting.append(call)
		rang = true
		if _on_line != null:
			_push(EventKind.CALL_WAITING, {"caller": call.caller, "queued": _waiting.size()})
	_scheduled = still
	return rang


func _tick_call(delta: float) -> void:
	if _on_line == null:
		return

	_call_left -= delta
	if _call_left > 0.0:
		return

	_resolve_call("aired", _on_line.aired_reaction, EventKind.CALL_AIRED)
	_take_the_line()


func _tick_improv(delta: float) -> void:
	_improv_left -= delta
	if _improv_left > 0.0:
		return

	var point := _current_improv()
	if point != null and point.options.size() > 0:
		_take_improv(point, 0, EventKind.IMPROV_TIMEOUT)
	else:
		_resume_from_improv()


func _tick_script(delta: float) -> void:
	var line := _current_line()
	if line == null:
		return

	_line_elapsed += delta
	# A palavra vai ao ar quando a leitura passa por ela, não no fim da
	# linha: é o prazo que dá sentido à varredura do teleprompter.
	_air_words_read_so_far(line)
	if _line_elapsed < line.read_seconds:
		return
	# Nenhuma ligação se perde na virada: o bloco espera a prévia, a fila e
	# quem ainda não foi acionada.
	if _line_index + 1 >= _script.lines.size() and _line_has_calls_pending():
		return

	_air_line(_line_index)
	_push(EventKind.LINE_ADVANCED, {"line_index": _line_index})

	if _line_index + 1 >= _script.lines.size():
		_state = State.FINISHED
		_push(EventKind.BLOCK_FINISHED, {})
		return

	_enter_line(_line_index + 1)


# =====================================================================
# Leitura de estado
# =====================================================================

func state() -> State:
	return _state


func start_break(kind: String) -> bool:
	if kind not in ["music", "ad"] or not _break_kind.is_empty() or _state in [State.READY, State.FINISHED]:
		return false
	_break_kind = kind
	_break_left = 6.0
	_push(EventKind.BREAK_STARTED, {"break_kind": kind})
	return true


func break_seconds_left() -> float:
	return _break_left


func break_kind() -> String:
	return _break_kind


func call_outcome() -> String:
	return _call_outcome


func reaction() -> String:
	return _reaction


func caller() -> String:
	if _on_line != null:
		return _on_line.caller
	return _results[-1]["call"].caller if not _results.is_empty() else "Ouvinte"


## Quantas tocaram e esperam a linha vagar.
func calls_waiting() -> int:
	return _waiting.size()


## O que aconteceu com cada ligação resolvida, na ordem: {call, outcome}.
func call_results() -> Array[Dictionary]:
	return _results.duplicate()


func is_finished() -> bool:
	return _state == State.FINISHED


func line_index() -> int:
	return _line_index


func line_count() -> int:
	return _script.lines.size()


func line_progress() -> float:
	var line := _current_line()
	if line == null or line.read_seconds <= 0.0:
		return 0.0
	return clampf(_line_elapsed / line.read_seconds, 0.0, 1.0)


## O texto da linha com as trocas que o jogador já fez.
func line_text(index: int) -> String:
	if index < 0 or index >= _script.lines.size():
		return ""

	var text: String = _script.lines[index].text
	for slot in _slots:
		if slot["line_index"] == index and slot["replaced"]:
			text = text.replace(slot["word"], slot["approved_synonym"])
	return text


## Todos os slots do roteiro, achatados, para o teleprompter poder
## endereçar qualquer um por índice.
func forbidden_slots() -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for slot in _slots:
		copy.append(slot.duplicate())
	return copy


func dead_air_seconds() -> float:
	return _dead_air


func infractions() -> Array[String]:
	return _infractions.duplicate()


## Ouvintes perdidos no silêncio. É o único efeito que o ao vivo calcula
## sozinho, porque é do ao vivo que ele nasce.
func dead_air_penalty() -> int:
	return -floori(DEAD_AIR_TRUST_PER_SECOND * _dead_air)


func chosen_improvs() -> Array[String]:
	return _chosen_improvs.duplicate()


## As frases que o jogador emendou. Os deltas e as consequências delas
## são aplicados pelo NightCycle, do mesmo jeito que os do enquadramento:
## este módulo não conhece medidor nenhum.
func chosen_improv_options() -> Array[ImprovOption]:
	return _chosen_options.duplicate()


func improv_prompt() -> String:
	var point := _current_improv()
	return point.prompt if point != null else ""


func improv_options() -> Array[ImprovOption]:
	var point := _current_improv()
	return point.options if point != null else [] as Array[ImprovOption]


func improv_seconds_left() -> float:
	return maxf(_improv_left, 0.0)


func call_transcript() -> String:
	return _on_line.transcript if _on_line != null else ""


func call_seconds_left() -> float:
	return maxf(_call_left, 0.0) if _on_line != null else 0.0


func has_pending_call() -> bool:
	return _on_line != null


func drain_events() -> Array[Dictionary]:
	var drained := _events
	_events = []
	return drained


# =====================================================================
# Interno
# =====================================================================

func _flatten_slots() -> void:
	for line_number in _script.lines.size():
		var line: ScriptLine = _script.lines[line_number]
		for slot_number in line.forbidden_slots.size():
			var slot: ForbiddenWordSlot = line.forbidden_slots[slot_number]
			_slots.append({
				"line_index": line_number,
				"slot_index": slot_number,
				"word": slot.word,
				"approved_synonym": slot.approved_synonym,
				"char_start": slot.char_start,
				"replaced": false,
				"aired": false,
			})


func _current_line() -> ScriptLine:
	if _line_index < 0 or _line_index >= _script.lines.size():
		return null
	return _script.lines[_line_index]


func _current_improv() -> ImprovPoint:
	var line := _current_line()
	return line.improv_point if line != null else null


func _improv_running() -> bool:
	return _improv_left > 0.0 and _current_improv() != null


func _enter_line(index: int) -> void:
	_line_index = index
	_line_elapsed = 0.0

	var was_silent: bool = _state == State.DEAD_AIR
	if not was_silent:
		_state = State.ON_AIR

	var point := _current_improv()
	if point == null:
		return

	# Entrar numa linha de improviso para o roteiro e liga o relógio,
	# mesmo que o microfone esteja solto (regra 7).
	_improv_left = point.time_limit_seconds
	if not was_silent:
		_state = State.IMPROV
	_push(EventKind.IMPROV_REQUESTED, {
		"point_id": point.id,
		"prompt": point.prompt,
		"time_limit": point.time_limit_seconds,
	})


func _take_improv(point: ImprovPoint, option_index: int, kind: EventKind) -> void:
	var option: ImprovOption = point.options[option_index]
	_chosen_improvs.append(option.id)
	_chosen_options.append(option)
	_improv_left = 0.0

	_push(kind, {
		"point_id": point.id,
		"option_id": option.id,
		"option_index": option_index,
		"text": option.text,
	})
	_resume_from_improv()


func _resume_from_improv() -> void:
	_improv_left = 0.0
	if _state == State.IMPROV:
		_state = State.ON_AIR
	elif _state == State.DEAD_AIR:
		_state_before_silence = State.ON_AIR


func _line_has_calls_pending() -> bool:
	return _on_line != null or not _waiting.is_empty() or not _scheduled.is_empty()


## Tudo o que a leitura já passou sai pela antena. A fração lida vale pelo
## texto original: trocar a palavra não muda o prazo dela.
func _air_words_read_so_far(line: ScriptLine) -> void:
	var length: int = maxi(line.text.length(), 1)
	var read: float = clampf(_line_elapsed / maxf(line.read_seconds, 0.001), 0.0, 1.0) * float(length)
	for slot in _slots:
		if slot["line_index"] != _line_index or slot["aired"]:
			continue
		if float(slot["char_start"]) + float(String(slot["word"]).length()) > read:
			continue
		_air_slot(slot)


func _air_slot(slot: Dictionary) -> void:
	slot["aired"] = true
	if slot["replaced"]:
		return
	_infractions.append(slot["word"])
	_push(EventKind.FORBIDDEN_WORD_AIRED, {
		"word": slot["word"], "line_index": slot["line_index"]})


## O que sobe na tela também sai pela antena: o que não foi trocado a
## tempo vira infração anotada.
func _air_line(index: int) -> void:
	for slot in _slots:
		if slot["line_index"] != index or slot["aired"]:
			continue
		_air_slot(slot)


func _push(kind: EventKind, data: Dictionary) -> void:
	data["kind"] = kind
	_events.append(data)
