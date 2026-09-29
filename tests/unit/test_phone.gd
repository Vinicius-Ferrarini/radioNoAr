extends GutTest

## O celular como celular: as mensagens chegam sozinhas, com data e hora,
## e a lista de conversas mostra a última fala de cada uma. O jogador não
## dispara nada ao pegar o aparelho.


# --- calendário ---

## Sem Time.: a data é aritmética pura, porque scripts/core/ não olha
## relógio de sistema (ADR 0007).
func test_night_one_is_the_fifteenth_of_july_of_2008() -> void:
	assert_eq(GameCalendar.date_of(1), "15/07/2008")
	assert_eq(GameCalendar.date_of(2), "16/07/2008")


func test_the_month_turns_over_correctly() -> void:
	assert_eq(GameCalendar.date_of(17), "31/07/2008")
	assert_eq(GameCalendar.date_of(18), "01/08/2008")
	assert_eq(GameCalendar.date_of(21), "04/08/2008")


func test_a_night_before_the_first_does_not_invent_a_date() -> void:
	assert_eq(GameCalendar.date_of(0), "15/07/2008")
	assert_eq(GameCalendar.date_of(-3), "15/07/2008")


# --- o relógio da noite ---

func test_the_night_always_starts_at_seven_in_the_evening() -> void:
	var clock := GameClock.new()
	assert_eq(clock.now(), "19:00")


func test_the_clock_walks_forward_with_the_night() -> void:
	var clock := GameClock.new()
	clock.tick(120.0)
	assert_eq(clock.now(), "20:00", "um minuto a cada dois segundos")
	clock.tick(-30.0)
	assert_eq(clock.now(), "20:00", "tempo não anda para trás")


func test_the_clock_turns_over_at_midnight() -> void:
	var clock := GameClock.new()
	clock.tick(5.0 * 60.0 * 2.0)
	assert_eq(clock.now(), "00:00", "cinco horas depois das 19h é meia-noite")
	clock.tick(2.0)
	assert_eq(clock.now(), "00:01")


# --- toda mensagem traz a hora em que foi mandada ---

func test_every_delivered_message_is_stamped_by_the_clock() -> void:
	var clock := GameClock.new()
	var first := ChatMessage.new()
	first.text = "Boa noite."
	first.delay_seconds = 0.0
	var second := ChatMessage.new()
	second.text = "Toca a valsa?"
	second.delay_seconds = 60.0
	var talk := Conversation.new([first, second] as Array[ChatMessage],
		[] as Array[ReplyOption], clock)

	assert_eq(talk.visible_messages()[0].at, "19:00")
	clock.tick(60.0)
	talk.tick(60.0)
	assert_eq(talk.visible_messages()[1].at, "19:30",
		"a segunda leva a hora de quando chegou, não a de quando foi escrita")


func test_stamps_never_go_backwards() -> void:
	var clock := GameClock.new()
	var thread: Array[ChatMessage] = []
	for i in 4:
		var message := ChatMessage.new()
		message.text = "fala %d" % i
		message.delay_seconds = 20.0
		thread.append(message)
	var talk := Conversation.new(thread, [] as Array[ReplyOption], clock)
	for i in 20:
		clock.tick(10.0)
		talk.tick(10.0)

	var previous := ""
	for message in talk.visible_messages():
		assert_false(message.at.is_empty(), "mensagem sem hora não existe")
		assert_true(message.at >= previous, "a lista fica ordenada por hora")
		previous = message.at


## O que o autor escreveu no conteúdo não pode ser escrito por cima: o
## recurso é compartilhado e sobreviveria à noite seguinte.
func test_stamping_does_not_write_on_the_content() -> void:
	var clock := GameClock.new()
	var written := ChatMessage.new()
	written.text = "Boa noite."
	written.delay_seconds = 0.0
	written.at = "escrito no conteudo"
	var talk := Conversation.new([written] as Array[ChatMessage],
		[] as Array[ReplyOption], clock)
	assert_eq(talk.visible_messages()[0].at, "19:00")
	assert_eq(written.at, "escrito no conteudo", "o recurso original fica intacto")


func test_your_own_reply_is_stamped_too() -> void:
	var clock := GameClock.new()
	var message := ChatMessage.new()
	message.text = "Toca a valsa?"
	message.delay_seconds = 0.0
	var reply := ReplyOption.new()
	reply.id = "sim"
	reply.text = "Toco sim."
	reply.framing_kind = FramingOption.Kind.AS_RECEIVED
	var talk := Conversation.new([message] as Array[ChatMessage],
		[reply] as Array[ReplyOption], clock)
	clock.tick(40.0)
	talk.send(0)
	assert_eq(talk.visible_messages()[1].at, "19:20", "a sua fala também tem hora")


# --- não lidas e última fala ---

func _talk() -> Conversation:
	var first := ChatMessage.new()
	first.text = "Boa noite."
	first.delay_seconds = 0.0
	first.at = "19:10"
	var second := ChatMessage.new()
	second.text = "Toca a nossa valsa?"
	second.delay_seconds = 2.0
	second.at = "19:12"
	return Conversation.new([first, second] as Array[ChatMessage], [] as Array[ReplyOption])


func test_unread_counts_what_arrived_while_you_were_not_looking() -> void:
	var talk := _talk()
	assert_eq(talk.unread(), 1, "a primeira chegou e você não abriu")

	talk.mark_read()
	assert_eq(talk.unread(), 0)

	talk.tick(3.0)
	assert_eq(talk.unread(), 1, "a segunda chegou depois de você fechar")


func test_your_own_line_never_counts_as_unread() -> void:
	var reply := ReplyOption.new()
	reply.id = "ok"
	reply.text = "Toco sim."
	reply.framing_kind = FramingOption.Kind.AS_RECEIVED
	var message := ChatMessage.new()
	message.delay_seconds = 0.0
	message.text = "Boa noite."
	var talk := Conversation.new([message] as Array[ChatMessage], [reply] as Array[ReplyOption])
	talk.mark_read()
	talk.send(0)
	assert_eq(talk.unread(), 0, "o que você mesmo mandou não é novidade")


func test_the_list_shows_the_last_message_and_its_time() -> void:
	var talk := _talk()
	assert_eq(talk.last_message().text, "Boa noite.")
	assert_eq(talk.last_at(), "19:10")

	talk.tick(3.0)
	assert_eq(talk.last_message().text, "Toca a nossa valsa?")
	assert_eq(talk.last_at(), "19:12")


# --- as conversas correm sozinhas na noite ---

func test_the_phone_is_already_talking_before_you_pick_it_up() -> void:
	GameState.start_run(7)
	var talk := GameState.conversation_of("p1_celia")
	assert_not_null(talk, "a conversa existe desde o começo da noite")
	var before: int = talk.visible_messages().size()

	# O jogador não abriu nada: só o tempo passou.
	for i in 100:
		GameState._process(0.1)
	assert_gt(talk.visible_messages().size(), before,
		"as mensagens chegam sem o jogador pegar o celular")


func test_every_phone_item_has_a_conversation_even_without_written_thread() -> void:
	GameState.start_run(7)
	for item in GameState.inbox():
		var talk := GameState.conversation_of(item.id)
		if item.channel == BroadcastItem.Channel.PHONE:
			assert_not_null(talk, "item de celular sem conversa: %s" % item.id)
			assert_gt(talk.visible_messages().size(), 0, item.id)
			assert_gt(talk.replies().size(), 0,
				"sem resposta o jogador não decide nada em %s" % item.id)
		else:
			assert_null(talk, "papel não é conversa: %s" % item.id)


func test_a_synthesized_reply_still_carries_the_framing() -> void:
	GameState.start_run(7)
	var talk := GameState.conversation_of("p1_placar")
	assert_not_null(talk)
	var kinds: Array[int] = []
	for reply in talk.replies():
		kinds.append(reply.framing_kind)
	assert_true(kinds.has(FramingOption.Kind.TRUTH),
		"o item do placar tem a fala da verdade, mesmo sem thread escrita")
