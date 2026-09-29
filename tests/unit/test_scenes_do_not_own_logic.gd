extends GutTest

## Cena nao guarda estado de jogo e nao instancia logica: ela escuta
## sinais do autoload e chama metodos dele (CLAUDE.md, SPEC secao 2).
## Sem este teste a regra vira boa intencao.

const SCENES_DIR := "res://scenes/"

## Instanciar qualquer um destes dentro de uma cena significa que a cena
## passou a ser dona de estado de jogo.
const FORBIDDEN_CONSTRUCTIONS := [
	"RunState.new(",
	"NightCycle.new(",
	"Meters.new(",
	"Notebook.new(",
	"Validator.new(",
	"ProgramRundown.new(",
	"ConsequenceQueue.new(",
	"GameStateLogic.new(",
	"RadioResources.new(",
]


func _scene_scripts() -> PackedStringArray:
	var paths := PackedStringArray()
	_collect_scripts(SCENES_DIR, paths)
	return paths


## Desce para as subpastas: scenes/parts/ tambem e apresentacao.
func _collect_scripts(directory: String, into: PackedStringArray) -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		return
	var file_names := dir.get_files()
	file_names.sort()
	for file_name in file_names:
		if file_name.ends_with(".gd"):
			into.append(directory + file_name)
	var sub_dirs := dir.get_directories()
	sub_dirs.sort()
	for sub_dir in sub_dirs:
		_collect_scripts(directory + sub_dir + "/", into)


func test_no_scene_instantiates_game_logic() -> void:
	var scripts := _scene_scripts()
	assert_gt(scripts.size(), 0, "deveria haver scripts de cena")
	for path in scripts:
		var source := FileAccess.get_file_as_string(path)
		for construction in FORBIDDEN_CONSTRUCTIONS:
			assert_false(source.contains(construction),
				"%s nao pode instanciar logica: %s" % [path, construction])


func test_no_scene_writes_to_a_resource_of_content() -> void:
	# Cena le conteudo; quem escreve em dado de jogo e a logica.
	for path in _scene_scripts():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("is_fraudulent"),
			"%s nao pode enxergar a verdade de bastidor do item" % path)
		assert_false(source.contains("ResourceSaver"),
			"%s nao deveria gravar recurso" % path)


func test_scene_scripts_reach_the_world_only_through_the_autoload() -> void:
	# A cena pode falar com GameState; nao pode carregar conteudo sozinha.
	for path in _scene_scripts():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("ContentLibrary."),
			"%s deveria pedir o conteudo ao GameState, nao carregar direto" % path)
		assert_false(source.contains("res://data/"),
			"%s nao deveria abrir arquivo de conteudo" % path)
