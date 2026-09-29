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
