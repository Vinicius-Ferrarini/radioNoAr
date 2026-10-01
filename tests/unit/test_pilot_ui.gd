extends GutTest

var desk: Control


func before_each() -> void:
	desk = load("res://scenes/studio_desk.tscn").instantiate()
	add_child_autofree(desk)
	GameState.set_process(false)
	await get_tree().process_frame


func after_each() -> void:
	GameState.set_process(true)


func _schedule() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	var items := GameState.inbox()
	for i in 4:
		desk._on_item_dropped(items[i].id, i)
		desk._on_framing_chosen(0)
	desk.get_node("Header/GoOnAirButton").pressed.emit()


func test_initial_briefing_and_framing_explain_the_work() -> void:
	assert_true(desk.get_node("Briefing").visible)
	assert_string_contains(desk.get_node("Briefing/Body").text, "aniversário")
	assert_true(desk.get_node("Briefing/Body") is Label,
		"o corpo simples não cria uma camada ou sombra sobre o papel")
	var clean_paper: ColorRect = desk.get_node("Briefing/BodyPaper")
	assert_true(clean_paper.visible)
	assert_true(clean_paper.get_rect().encloses(desk.get_node("Briefing/Body").get_rect()),
		"o papel limpo cobre a faixa decorativa atrás do corpo")
	assert_eq(desk.get_node("Header/QuotaLabel").text, "PROGRAMA LIVRE")
	desk.get_node("Briefing/Start").pressed.emit()

	# O portão de evidência mudou de superfície com o ADR 0013: não é mais
	# uma linha travada na régua, é uma resposta que você ainda não pode
	# mandar. A regra por baixo é a mesma.
	desk._on_item_dropped("p1_placar", 0)
	# O Toledo manda quatro falas antes de calar: não se responde no meio da
	# rajada, então a opção travada só aparece quando ele termina.
	_wait_for_her_to_finish()
	var truth := _locked_truth_reply()
	assert_not_null(truth, "a fala da verdade aparece travada antes de apurar")
	assert_true(truth.disabled)
	assert_string_contains(truth.text, "conferir")

	GameState.link_claim("p1_placar", "p1_placar_claim", "p_placar")
	desk._refresh_item()
	assert_null(_locked_truth_reply(), "cruzada a evidência, a fala destrava")


## A resposta travada do item aberto, ou nulo se todas estão liberadas.
func _locked_truth_reply() -> Button:
	for row in _reply_rows():
		if row.disabled:
			return row
	return null


## --- a conversa é a decisão (ADR 0013) ---

func _thread_bubbles() -> Array:
	return desk.get_node("Closes/ClosePhone/ChatScroll/Thread").get_children()


func _reply_rows() -> Array:
	return desk.get_node("Closes/ClosePhone/DecisionPanel/DecisionContent/ReplyScroll/Replies").get_children()


func _wait_for_her_to_finish() -> void:
	for i in 100:
		GameState._process(0.1)
	desk._refresh_item()


## A rajada chega aos poucos e a régua não aparece: o celular é o lugar
## da decisão agora.
func test_the_conversation_arrives_one_message_at_a_time() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_celia")
	assert_eq(_thread_bubbles().size(), 1, "ela ainda está digitando o resto")
	assert_eq(_reply_rows().size(), 0, "não se responde no meio da frase")
	assert_true(desk.get_node("Closes/ClosePhone").visible,
		"quem abre é o aparelho, não o close de papel")
	assert_false(desk.get_node("Closes/CloseItem").visible)

	_wait_for_her_to_finish()
	assert_eq(_thread_bubbles().size(), 6, "a rajada dela tem seis falas curtas")
	assert_eq(_reply_rows().size(), 3, "as três respostas ficam no painel de decisão")
	assert_true(desk.get_node("Closes/ClosePhone/DecisionPanel").visible)
	assert_false(desk.get_node("Closes/FramingStrip").visible, "a régua não entra aqui")
	assert_gt(desk.get_node("Closes/ClosePhone/ChatScroll").size.y, 100.0,
		"o histórico usa a altura do aparelho em vez de só uma faixa")


func test_reply_buttons_never_leave_the_decision_panel() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_oficina")
	_wait_for_her_to_finish()
	await get_tree().process_frame
	var panel: Rect2 = desk.get_node("Closes/ClosePhone/DecisionPanel").get_global_rect()
	for row in _reply_rows():
		var rect: Rect2 = row.get_global_rect()
		assert_gte(rect.position.x, panel.position.x)
		assert_lte(rect.end.x, panel.end.x)
		assert_gte(rect.position.y, panel.position.y)
		assert_lte(rect.end.y, panel.end.y,
			"resposta não pode escapar por baixo do painel")


func test_chat_scrolls_to_first_unread_and_clamps_short_threads() -> void:
	var phone: Control = desk.get_node("Closes/ClosePhone")
	var messages: Array[ChatMessage] = []
	for index in 12:
		var message := ChatMessage.new()
		message.text = "Mensagem longa número %d para ocupar duas linhas." % index
		message.at = "19:%02d" % index
		messages.append(message)
	phone.show_chat("Teste", messages, [], [], [], [], 5)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll: ScrollContainer = phone.get_node("ChatScroll")
	var target: Control = phone.get_node("ChatScroll/Thread").get_child(5)
	var maximum := int(scroll.get_v_scroll_bar().max_value - scroll.get_v_scroll_bar().page)
	assert_eq(scroll.scroll_vertical, mini(int(target.position.y), maximum))

	phone.show_chat("Teste", messages.slice(0, 2), [], [], [], [], 1)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(scroll.scroll_vertical, 0,
		"duas mensagens usam o espaço disponível sem fabricar vazio")


func test_opening_a_real_unread_thread_starts_at_its_first_message() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	for index in 100:
		GameState._process(0.1)
	var talk := GameState.conversation_of("p1_celia")
	assert_eq(talk.first_unread_index(), 0)
	desk._open_item("p1_celia")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(desk.get_node("Closes/ClosePhone/ChatScroll").scroll_vertical, 0,
		"a primeira abertura não pode começar no meio da rajada")


## O defeito relatado no playtest do celular: balão em cima do outro e
## texto cortado. A causa era altura fixa num NinePatchRect, que não cresce
## com o filho.
func test_bubbles_never_overlap_nor_run_past_the_screen() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_celia")
	_wait_for_her_to_finish()
	await get_tree().process_frame

	var scroll: ScrollContainer = desk.get_node("Closes/ClosePhone/ChatScroll")
	var limit: float = scroll.get_global_rect().end.x
	var bubbles := _thread_bubbles()
	assert_gt(bubbles.size(), 3, "a rajada da Célia tem mais de três falas")
	var previous := Rect2()
	for bubble in bubbles:
		var rect: Rect2 = bubble.get_global_rect()
		assert_true(bubble.get_theme_stylebox("panel") is StyleBoxFlat,
			"o balão é uma caixa exata, sem cauda de textura")
		assert_gt(rect.size.y, 0.0, "balão sem altura não mostra texto")
		if previous.size.y > 0.0:
			assert_gte(rect.position.y, previous.end.y - 0.5,
				"um balão não pode começar antes do fim do anterior")
		assert_lte(rect.end.x, limit + 1.0, "balão não passa da tela do aparelho")
		previous = rect


## A data de hoje fica à vista, e a hora vem em cada fala.
func test_the_phone_shows_today_and_the_time_of_each_burst() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	assert_eq(desk.get_node("Closes/ClosePhone/Today").text, "15/07/2008",
		"noite 1 é 15 de julho de 2008")
	assert_string_contains(desk.get_node("Briefing/Title").text, "15/07/2008",
		"a data também abre a noite")
	desk._open_item("p1_celia")
	_wait_for_her_to_finish()
	# Toda fala traz a hora, e as horas ficam em ordem de chegada. Nada de
	# agrupar: a conversa tem de poder ser lida fora de ordem depois.
	var bubbles := _thread_bubbles()
	assert_gt(bubbles.size(), 0)
	var previous := ""
	for bubble in bubbles:
		var at: String = bubble.get_node("Lines/At").text
		assert_false(at.is_empty(), "balão sem hora: '%s'" % bubble.get_node("Lines/Text").text)
		assert_true(at >= previous, "as horas sobem junto com a conversa")
		previous = at
	assert_eq(_thread_bubbles()[0].get_node("Lines/At").text, "19:00",
		"a primeira fala chega com o relógio no começo da noite")


## O relógio do canto anda sozinho enquanto a noite corre.
func test_the_phone_clock_walks_with_the_night() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_celia")
	assert_eq(desk.get_node("Closes/ClosePhone/Clock").text, "19:00")
	# Passos exatos: 300 passos de 0,1 s somam 29,99 s e o relógio, que
	# trunca o minuto em curso, mostraria 19:14.
	for i in 6:
		GameState._process(5.0)
	desk._process(0.0)
	assert_eq(desk.get_node("Closes/ClosePhone/Clock").text, "19:15",
		"trinta segundos de jogo são quinze minutos de programa")


## O que você responde entra na thread e no roteiro sem uma segunda etapa.
func test_the_reply_becomes_your_bubble_and_enters_the_rundown() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_celia")
	_wait_for_her_to_finish()

	var rows := _reply_rows()
	rows[0].row_pressed.emit(rows[0].row_id())
	assert_true(desk.get_node("RundownTransfer").visible,
		"um cartão sai do celular quando a resposta entra no roteiro")
	desk._refresh_item()

	var mine := _thread_bubbles().filter(func(b: Node) -> bool: return b.get_node("Lines/Text").text == "Dou os parabéns no ar.")
	assert_eq(mine.size(), 1, "a sua fala entra na thread")
	assert_eq(_reply_rows().size(), 0, "respondido, não há mais o que escolher")

	assert_eq(GameState.block_of_item("p1_celia"), 0,
		"responder confirma a pauta automaticamente")
	assert_eq(GameState.block_framing(0), FramingOption.Kind.AS_RECEIVED,
		"o roteiro usa exatamente o que você prometeu")
	assert_string_contains(desk.get_node("RundownPaper/Paper/ListScroll/List").get_child(0).text, "Dar os parabéns")
	await get_tree().process_frame
	assert_false(desk.get_node("RundownPaper").is_collapsed(),
		"a pauta nova faz o roteiro subir")
	await get_tree().create_timer(1.4).timeout
	assert_true(desk.get_node("RundownPaper").is_collapsed(),
		"depois de receber o cartão, o roteiro volta para a borda")


func test_phone_shows_the_contact_portrait_in_list_and_chat() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_phone()
	var rows := desk.get_node("Closes/ClosePhone/ListScroll/List").get_children()
	assert_gt(rows.size(), 0)
	var first_avatar: TextureRect = rows[0].get_node("Avatar")
	assert_not_null(first_avatar.texture, "a lista identifica cada conversa pela foto")
	assert_eq(first_avatar.custom_minimum_size, Vector2(32, 32))

	desk._open_item("p1_celia")
	var header_avatar: TextureRect = desk.get_node("Closes/ClosePhone/ContactAvatar")
	assert_true(header_avatar.visible)
	assert_not_null(header_avatar.texture)
	assert_eq(header_avatar.size, Vector2(32, 32))
	assert_string_contains(header_avatar.texture.resource_path, "avatar_celia.png")
	assert_eq(desk.get_node("Closes/ClosePhone/ContactHandle").text, "(fixo) 2-4417")


func test_the_larger_phone_uses_its_bezel_for_close() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_phone()
	var phone: Control = desk.get_node("Closes/ClosePhone")
	assert_eq(phone.get_node("Body").size, Vector2(156, 166))
	assert_lt(phone.get_node("CloseButton").position.y,
		phone.get_node("Title").position.y,
		"fechar fica na moldura superior e não disputa o cabeçalho")


## Enquanto não há resposta, o roteiro segue vazio e a mesa abre o celular.
func test_an_undecided_conversation_points_to_the_phone() -> void:
	desk.get_node("Briefing/Start").pressed.emit()
	desk.get_node("EnterAirButton").pressed.emit()
	assert_string_contains(desk.get_node("Feedback").text, "Responda no celular")
	assert_true(desk.get_node("Closes/ClosePhone").visible)
	assert_eq(GameState.block_of_item("p1_celia"), -1)


func test_visible_controls_cut_call_preserve_reaction_and_reach_morning() -> void:
	_schedule()
	assert_true(desk.get_node("Notebook").visible)
	desk.get_node("Studio/Microphone").pressed.emit()
	assert_true(GameState.microphone_open())
	var steps := 0
	while not GameState.live_console().get("pending", false) and steps < 1000:
		GameState._process(0.1)
		steps += 1
	assert_lt(steps, 1000)
	desk._refresh_live()
	assert_false(desk.get_node("CallPanel/Cut").disabled)
	assert_string_contains(desk.get_node("CallPanel/Status").text, "PRÉVIA")
	desk.get_node("CallPanel/Cut").pressed.emit()
	assert_string_contains(desk.get_node("CallPanel/Status").text, "CORTADO")
	assert_string_contains(desk.get_node("CallPanel/Transcript").text, "Essa eu te devo",
		"a reação do corte aparece na hora")

	steps = 0
	while not GameState.is_live_done() and steps < 2000:
		GameState._process(0.1)
		steps += 1
	assert_lt(steps, 2000)
	desk._refresh_live()
	# Desde a Fase 2 a noite tem mais de uma ligação, e o painel fala da
	# última resolvida. O que este teste garante é que a reação não
	# desaparece na virada de bloco.
	assert_false(desk.get_node("CallPanel/Transcript").text.is_empty(),
		"a reação da última ligação continua na tela")
	assert_false(desk.get_node("CallPanel/Status").text.contains("LINHA LIVRE"),
		"o console não volta a dizer que a linha está livre depois de atender")
	assert_eq(desk.get_node("Header/GoOnAirButton").text, "MANHÃ")
	desk.get_node("Header/GoOnAirButton").pressed.emit()
	assert_true(desk.get_node("Closes/CloseMorning").visible)
	desk.get_node("Closes/CloseMorning/ContinueButton").pressed.emit()
	assert_eq(GameState.current_night(), 2)
	assert_true(desk.get_node("Briefing").visible)


func test_space_is_a_toggle_not_a_hold() -> void:
	_schedule()
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	key.pressed = true
	desk._input(key)
	assert_true(GameState.microphone_open())
	key.pressed = false
	desk._input(key)
	assert_true(GameState.microphone_open(), "soltar não fecha o microfone")
	key.pressed = true
	desk._input(key)
	assert_false(GameState.microphone_open())
