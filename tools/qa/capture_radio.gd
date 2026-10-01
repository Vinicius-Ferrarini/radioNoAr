extends SceneTree

## Percorre UI real e captura imagens renderizadas. Precisa de renderer
## (não usar --headless). Saídas ficam em .godot/radio-qa/.
var desk: Control
var game: Node
var canvas: Control


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.godot/radio-qa")
	canvas = load("res://scenes/game_canvas.tscn").instantiate()
	root.add_child(canvas)
	desk = canvas.get_node("StudioDesk")
	game = root.get_node("GameState")
	game.set_process(false)
	await _capture("01-abertura")
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_nilo")
	await _capture("02-documento-com-decisoes")
	desk._open_item("p1_placar")
	desk._on_claim_marked("p1_placar_claim")
	await _capture("03-apuracao")
	desk._on_notebook_entry_chosen("p_placar")
	while not game.conversation_of("p1_celia").is_waiting_for_reply():
		game._process(0.2)
	desk._open_item("p1_celia")
	await _capture("04-chat-e-decisoes")
	desk._on_reply_chosen(0)
	await _capture("05-cartao-para-roteiro")
	desk._open_item("p1_oficina")
	while not game.conversation_of("p1_oficina").is_waiting_for_reply():
		game._process(0.2)
	desk._on_reply_chosen(0)
	desk._open_phone()
	await _capture("06-celular-por-recencia")
	await create_timer(1.2).timeout
	desk._show_desk()
	await _capture("07-roteiro-automatico")
	desk.get_node("RundownPaper").toggle_collapsed()
	await create_timer(0.25).timeout
	await _capture("08-roteiro-aberto-manual")
	desk.get_node("RundownPaper").toggle_collapsed()
	await create_timer(0.25).timeout
	_schedule()
	desk.get_node("Studio/Microphone").pressed.emit()
	while not game.live_console().get("pending", false):
		game._process(0.1)
	desk._refresh_live()
	await _capture("09-ligacao")
	desk.get_node("LiveControls/Music").pressed.emit()
	game._process(0.1)
	desk._refresh_live()
	await _capture("10-intervalo")
	desk.get_node("CallPanel/Cut").pressed.emit()
	_finish()
	desk.get_node("Header/GoOnAirButton").pressed.emit()
	await _capture("11-manha")
	desk.get_node("Closes/CloseMorning/ContinueButton").pressed.emit()
	await _capture("12-segunda-noite")
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p2_boletim")
	desk._on_claim_marked("p2_boletim_claim")
	desk._on_notebook_entry_chosen("p_ponte")
	desk._show_desk()
	_schedule()
	game.set_mic_held(true)
	_finish()
	desk.get_node("Header/GoOnAirButton").pressed.emit()
	desk.get_node("Closes/CloseMorning/ContinueButton").pressed.emit()
	await _capture("13-terceira-noite")
	print("QA: treze capturas e navegação até a terceira noite concluídas.")
	quit()


func _schedule() -> void:
	var items: Array = game.inbox()
	for i in 4:
		desk._on_item_dropped(items[i].id, i)
		desk._on_framing_chosen(0)
	desk._on_go_on_air_pressed()


func _finish() -> void:
	for i in 2500:
		if game.is_live_done():
			break
		game._process(0.1)
	desk._refresh_live()
	assert(game.is_live_done(), "programa não terminou")


func _capture(id: String) -> void:
	await process_frame
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png("res://.godot/radio-qa/" + id + ".png")
	assert(error == OK)
	print("QA captura: ", id)
