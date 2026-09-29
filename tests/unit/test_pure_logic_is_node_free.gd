extends GutTest

## A camada de logica pura nao conhece Node, relogio, sorteio global nem
## arvore de cena (CLAUDE.md, ADR 0007). Sem este teste a regra depende
## de disciplina, e regra que depende de disciplina acaba quebrada — no
## dia em que alguem "so precisa de um Timer aqui".

const CORE_DIR := "res://scripts/core/"

## O que nao pode aparecer em scripts/core/, e por que.
const FORBIDDEN := {
	"Time.": "relogio global: quebra o tempo injetado",
	"get_ticks": "relogio global: quebra o tempo injetado",
	"Timer": "Timer e Node",
	"await ": "espera implica arvore de cena",
	"get_tree": "arvore de cena",
	"Input.": "entrada e coisa da camada de apresentacao",
	"randi(": "sorteio global: quebra a reprodutibilidade por seed",
	"randf(": "sorteio global: quebra a reprodutibilidade por seed",
	"randomize(": "sorteio global: quebra a reprodutibilidade por seed",
	"_draw": "UI nunca usa _draw",
	"_process(": "so o autoload tem _process",
	"OS.": "sistema operacional nao e assunto da logica",
}


func _core_scripts() -> PackedStringArray:
	var paths := PackedStringArray()
	_collect(CORE_DIR, paths)
	return paths


func _collect(directory: String, into: PackedStringArray) -> void:
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
		_collect(directory + sub_dir + "/", into)


func test_the_core_has_scripts_to_check() -> void:
	assert_gt(_core_scripts().size(), 10, "deveria haver logica pura para conferir")


func test_no_core_script_uses_a_forbidden_identifier() -> void:
	for path in _core_scripts():
		var source := FileAccess.get_file_as_string(path)
		for identifier in FORBIDDEN:
			assert_false(source.contains(identifier),
				"%s usa '%s' — %s" % [path, identifier, FORBIDDEN[identifier]])


func test_no_core_script_extends_node() -> void:
	for path in _core_scripts():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("extends Node"),
			"%s deveria ser RefCounted ou Resource" % path)


func test_no_core_script_declares_a_signal() -> void:
	# A logica pura acumula ocorrencias e entrega por drain_events(); quem
	# transforma isso em sinal e o autoload (ADR 0007).
	for path in _core_scripts():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("\nsignal "),
			"%s nao deveria declarar signal" % path)


func test_the_only_process_in_the_project_is_the_autoload() -> void:
	var autoload_source := FileAccess.get_file_as_string("res://scripts/game_state.gd")
	assert_true(autoload_source.contains("func _process("),
		"o autoload e o unico ponto por onde o tempo entra")
