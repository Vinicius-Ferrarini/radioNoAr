extends GutTest

## O critério de aceite do M7 dizia "project.godot com integer scaling".
## Sem este teste isso era só uma linha num arquivo que eu editei e
## conferi de olho. Uma configuração errada aqui não quebra teste
## nenhum — só faz o jogo abrir feio, ou minúsculo.


func test_base_resolution_is_640x360() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), 360)


func test_the_window_opens_at_an_integer_multiple_of_the_base() -> void:
	var width: int = ProjectSettings.get_setting("display/window/size/window_width_override")
	var height: int = ProjectSettings.get_setting("display/window/size/window_height_override")
	assert_gt(width, 640, "a janela nao pode abrir do tamanho do viewport")
	assert_eq(width % 640, 0, "a largura da janela deveria ser multiplo inteiro de 640")
	assert_eq(height % 360, 0, "a altura da janela deveria ser multiplo inteiro de 360")
	assert_eq(width / 640, height / 360, "os dois eixos precisam da mesma escala")


func test_stretch_keeps_pixels_square_and_text_sharp() -> void:
	# canvas_items + integer e o que permite o hibrido do ADR 0006:
	# sprite em escala inteira e fonte rasterizada na resolucao da janela.
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "canvas_items")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "integer")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/aspect"), "keep",
		"o jogo e uma tela fixa: tela larga ganha barra, nao mais mundo")


func test_textures_are_not_filtered() -> void:
	# 0 = Nearest. Com filtro linear a pixel art vira mingau.
	assert_eq(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"), 0)


func test_the_main_scene_is_the_double_density_canvas() -> void:
	assert_eq(ProjectSettings.get_setting("application/run/main_scene"),
		"res://scenes/game_canvas.tscn")
	var canvas: Control = load("res://scenes/game_canvas.tscn").instantiate()
	add_child_autofree(canvas)
	await get_tree().process_frame
	var desk: Control = canvas.get_node("StudioDesk")
	assert_eq(desk.scale, Vector2.ONE, "a mesa deve ser composta no canvas nativo")
	assert_eq(desk.size, Vector2(640, 360))


func test_the_autoload_is_registered() -> void:
	assert_eq(ProjectSettings.get_setting("autoload/GameState"),
		"*res://scripts/game_state.gd")
