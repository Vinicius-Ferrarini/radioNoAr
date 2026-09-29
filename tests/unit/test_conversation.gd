extends GutTest

## A conversa é onde a decisão editorial passa a acontecer (ADR 0013).
## Aqui se testa só a lógica: quem fala, quando aparece, quando é a sua
## vez e o que a sua resposta decide. Nada de cena.


func _message(text: String, from_me: bool, delay := 1.0) -> ChatMessage:
	var message := ChatMessage.new()
	message.text = text
	message.from_me = from_me
	message.delay_seconds = delay
	return message


func _reply(id: String, text: String, kind: int, answer: Array = []) -> ReplyOption:
	var reply := ReplyOption.new()
	reply.id = id
	reply.text = text
	reply.framing_kind = kind
	var typed: Array[ChatMessage] = []
	for message in answer:
		typed.append(message)
	reply.answer = typed
	return reply


func _conversation() -> Conversation:
	var thread: Array[ChatMessage] = [
		_message("Boa noite, seu Nilo.", false, 0.0),
		_message("Hoje é aniversário do meu marido.", false, 2.0),
	]
	var replies: Array[ReplyOption] = [
		_reply("parabens", "Vou dar os parabéns no ar.", FramingOption.Kind.AS_RECEIVED,
			[_message("Ele vai chorar, viu?", false, 1.0)]),
		_reply("guardar", "Hoje não dá, dona Célia.", FramingOption.Kind.DISCARD),
	]
	return Conversation.new(thread, replies)


func test_messages_arrive_one_at_a_time() -> void:
	var talk := _conversation()
	assert_eq(talk.visible_messages().size(), 1, "a primeira chega sem espera")

	talk.tick(1.0)
	assert_eq(talk.visible_messages().size(), 1, "a segunda ainda está sendo digitada")

	talk.tick(1.5)
	assert_eq(talk.visible_messages().size(), 2)
	assert_eq(talk.visible_messages()[1].text, "Hoje é aniversário do meu marido.")


func test_you_do_not_answer_in_the_middle_of_a_sentence() -> void:
	var talk := _conversation()
	assert_false(talk.is_waiting_for_reply(), "ela ainda não terminou de falar")
	assert_false(talk.send(0), "não dá para responder antes do fim da rajada")

	talk.tick(3.0)
	assert_true(talk.is_waiting_for_reply())
	assert_true(talk.send(0))


func test_sending_records_your_line_and_queues_the_answer() -> void:
	var talk := _conversation()
	talk.tick(3.0)
	talk.send(0)

	var visible := talk.visible_messages()
	assert_eq(visible.size(), 3, "a sua fala entra na thread na hora")
	assert_true(visible[2].from_me, "a terceira é sua")
	assert_eq(visible[2].text, "Vou dar os parabéns no ar.")
	assert_false(talk.is_waiting_for_reply(), "agora é a vez dela")

	talk.tick(2.0)
	assert_eq(talk.visible_messages().size(), 4)
	assert_eq(talk.visible_messages()[3].text, "Ele vai chorar, viu?")


func test_one_decision_per_night() -> void:
	var talk := _conversation()
	talk.tick(3.0)
	assert_true(talk.send(0))
	assert_false(talk.send(1), "já foi dito; não se desdiz no mesmo dia")
	assert_eq(talk.chosen_reply_id(), "parabens")


func test_the_reply_decides_the_framing() -> void:
	var talk := _conversation()
	assert_eq(talk.chosen_framing_kind(), -1, "antes de responder não há decisão")
	talk.tick(3.0)
	talk.send(1)
	assert_eq(talk.chosen_framing_kind(), FramingOption.Kind.DISCARD)
	assert_true(talk.is_decided())


func test_events_report_what_happened_and_drain() -> void:
	var talk := _conversation()
	talk.drain_events()
	talk.tick(3.0)
	var kinds: Array[int] = []
	for event in talk.drain_events():
		kinds.append(int(event["kind"]))
	assert_true(kinds.has(Conversation.EventKind.MESSAGE_ARRIVED))
	assert_true(kinds.has(Conversation.EventKind.THREAD_IDLE),
		"a cena precisa saber que agora é a vez do jogador")
	assert_eq(talk.drain_events().size(), 0, "drenar duas vezes não repete")

	talk.send(0)
	var sent := talk.drain_events()
	assert_eq(int(sent[0]["kind"]), Conversation.EventKind.REPLY_SENT)
	assert_eq(String(sent[0]["reply_id"]), "parabens")


func test_time_only_moves_forward() -> void:
	var talk := _conversation()
	talk.tick(-5.0)
	talk.tick(0.0)
	assert_eq(talk.visible_messages().size(), 1, "tempo parado não entrega mensagem")


func test_a_reply_index_outside_the_list_does_nothing() -> void:
	var talk := _conversation()
	talk.tick(3.0)
	assert_false(talk.send(-1))
	assert_false(talk.send(99))
	assert_false(talk.is_decided())


func test_a_thread_with_no_replies_never_waits() -> void:
	var thread: Array[ChatMessage] = [_message("Comunicado oficial.", false, 0.0)]
	var talk := Conversation.new(thread, [] as Array[ReplyOption])
	talk.tick(5.0)
	assert_false(talk.is_waiting_for_reply(),
		"sem resposta possível, a conversa não cobra decisão")
	assert_false(talk.is_decided())
