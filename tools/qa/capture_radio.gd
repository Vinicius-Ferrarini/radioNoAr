extends SceneTree

## Percorre UI real e captura imagens renderizadas. Precisa de renderer
## (não usar --headless). Saídas ficam em .godot/radio-qa/.
var desk: Control
var game: Node


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.godot/radio-qa")
	desk = load("res://scenes/studio_desk.tscn").instantiate()
	root.add_child(desk)
	game = root.get_node("GameState")
	game.set_process(false)
	await _capture("01-abertura")
	desk.get_node("Briefing/Start").pressed.emit()
	desk._open_item("p1_placar")
	desk._on_claim_marked("p1_placar_claim")
	await _capture("02-apuracao")
	desk._on_notebook_entry_chosen("p_placar")
	desk._show_desk()
	_schedule()
	desk.get_node("Studio/Microphone").pressed.emit()
	while not game.live_console().get("pending", false):
		game._process(0.1)
	desk._refresh_live()
	await _capture("03-ligacao")
	desk.get_node("LiveControls/Music").pressed.emit()
	game._process(0.1)
	desk._refresh_live()
	await _capture("04-intervalo")
	desk.get_node("CallPanel/Cut").pressed.emit()
	_finish()
	desk.get_node("Header/GoOnAirButton").pressed.emit()
	await _capture("05-manha")
	desk.get_node("Closes/CloseMorning/ContinueButton").pressed.emit()
	await _capture("06-segunda-noite")
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
	await _capture("07-terceira-noite")
	print("QA: sete capturas e navegação até a terceira noite concluídas.")
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
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png("res://.godot/radio-qa/" + id + ".png")
	assert(error == OK)
	print("QA captura: ", id)
