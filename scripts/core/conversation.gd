class_name Conversation
extends RefCounted

## A conversa do celular, onde a decisão editorial passa a acontecer
## (ADR 0013). Antes era ler um parágrafo e escolher um rótulo numa
## régua; agora é falar com uma pessoa, e o que você responde decide se
## aquilo vai ao ar e como.
##
## Não conhece Node, não olha relógio e não emite sinal: o tempo entra
## por tick(delta) e o que aconteceu sai por drain_events() (ADR 0007).
## Assim a espera entre mensagens — que é o que dá o ritmo de conversa —
## é testável em milissegundos e sempre igual.
##
## Quem traduz a decisão em enquadramento de bloco é o GameState.

enum EventKind {
	MESSAGE_ARRIVED,
	## A rajada terminou e existe resposta possível: é a sua vez.
	THREAD_IDLE,
	REPLY_SENT,
}

var _replies: Array[ReplyOption] = []

## Já entregues, na ordem em que apareceram.
var _visible: Array[ChatMessage] = []
## Ainda por chegar, na ordem.
var _queue: Array[ChatMessage] = []
## Quanto falta para a cabeça da fila aparecer, e se essa espera já foi
## armada. Sem o par, um tick picado em pedaços menores que a espera
## rearmaria o relógio para sempre.
var _wait: float = 0.0
var _armed: bool = false

var _chosen: ReplyOption = null
var _announced_idle: bool = false

var _events: Array[Dictionary] = []


func _init(thread: Array[ChatMessage], replies: Array[ReplyOption]) -> void:
	_replies = replies.duplicate()
	_queue = thread.duplicate()
	_deliver_due()


# =====================================================================
# O tempo
# =====================================================================

func tick(delta: float) -> void:
	if delta <= 0.0:
		return

	_wait -= delta
	_deliver_due()


# =====================================================================
# Entrada do jogador
# =====================================================================

## Manda a resposta de índice `index`. Falso quando não é a sua vez, o
## índice não existe ou você já disse o que tinha para dizer.
func send(index: int) -> bool:
	if not is_waiting_for_reply():
		return false
	if index < 0 or index >= _replies.size():
		return false

	var reply: ReplyOption = _replies[index]
	_chosen = reply

	# A sua fala entra na hora: quem escreve não espera para se ver.
	var said := ChatMessage.new()
	said.from_me = true
	said.text = reply.text
	_visible.append(said)

	for message in reply.answer:
		_queue.append(message)
	_announced_idle = false
	_wait = 0.0
	_armed = false

	_push(EventKind.REPLY_SENT, {"reply_id": reply.id, "framing_kind": reply.framing_kind})
	_deliver_due()
	return true


# =====================================================================
# Leitura de estado
# =====================================================================

func visible_messages() -> Array[ChatMessage]:
	return _visible.duplicate()


## Só depois que a pessoa terminou a rajada. Responder no meio da frase
## não é conversa.
func is_waiting_for_reply() -> bool:
	return _queue.is_empty() and not _replies.is_empty() and _chosen == null


func replies() -> Array[ReplyOption]:
	return _replies.duplicate()


func is_decided() -> bool:
	return _chosen != null


func chosen_reply_id() -> String:
	return _chosen.id if _chosen != null else ""


## -1 enquanto não há decisão. O chamador compara com FramingOption.Kind.
func chosen_framing_kind() -> int:
	return _chosen.framing_kind if _chosen != null else -1


func drain_events() -> Array[Dictionary]:
	var drained := _events
	_events = []
	return drained


# =====================================================================
# Interno
# =====================================================================

## Entrega tudo cuja espera já venceu. O tempo que passou do ponto é
## creditado na mensagem seguinte: uma pausa longa não engole a próxima.
func _deliver_due() -> void:
	while not _queue.is_empty():
		if not _armed:
			# A primeira fala da conversa não faz o jogador esperar.
			_wait = 0.0 if _visible.is_empty() else _queue[0].delay_seconds + minf(_wait, 0.0)
			_armed = true
		if _wait > 0.0:
			return

		var next: ChatMessage = _queue[0]
		_queue.remove_at(0)
		_visible.append(next)
		_armed = false
		_push(EventKind.MESSAGE_ARRIVED, {"text": next.text, "from_me": next.from_me})

	if is_waiting_for_reply() and not _announced_idle:
		_announced_idle = true
		_push(EventKind.THREAD_IDLE, {"replies": _replies.size()})


func _push(kind: EventKind, data: Dictionary) -> void:
	data["kind"] = kind
	_events.append(data)
