extends GutTest

## A UI tem que ficar editavel no editor do Godot: nada de _draw().
## Esta e uma regra de arquitetura do CLAUDE.md, e regra de arquitetura
## que depende de disciplina acaba quebrada.

const SCENES_DIR := "res://scenes/"


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


func test_no_scene_script_defines_custom_draw() -> void:
	var scripts := _scene_scripts()
	assert_gt(scripts.size(), 0, "deveria haver scripts de cena para conferir")
	for path in scripts:
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("func _draw"), "%s nao pode ter _draw()" % path)


func test_scene_files_do_not_use_custom_draw_nodes() -> void:
	var dir := DirAccess.open(SCENES_DIR)
	assert_not_null(dir)
	var checked := 0
	for file_name in dir.get_files():
		if not file_name.ends_with(".tscn"):
			continue
		var source := FileAccess.get_file_as_string(SCENES_DIR + file_name)
		assert_false(source.contains("type=\"Node2D\""),
			"%s: a UI e feita de nos Control" % file_name)
		checked += 1
	assert_gt(checked, 0, "deveria haver cenas para conferir")
