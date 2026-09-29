extends GutTest


func _make_entry(id: String, category: int, key: String) -> NotebookEntry:
	var entry := NotebookEntry.new()
	entry.id = id
	entry.category = category
	entry.key = key
	entry.text = "texto de %s" % id
	entry.night_added = 1
	return entry


func test_add_entry_stores_the_entry() -> void:
	var notebook := Notebook.new()
	var added: bool = notebook.add_entry(_make_entry("e1", NotebookEntry.Category.CURFEW, "centro"))
	assert_true(added, "add_entry deveria devolver true para id novo")
	assert_eq(notebook.all_entries().size(), 1, "caderno deveria ter 1 entrada")


func test_add_entry_with_duplicated_id_is_rejected() -> void:
	var notebook := Notebook.new()
	notebook.add_entry(_make_entry("e1", NotebookEntry.Category.CURFEW, "centro"))
	var added: bool = notebook.add_entry(_make_entry("e1", NotebookEntry.Category.DETAINED, "outro"))
	assert_false(added, "add_entry deveria devolver false para id repetido")
	assert_eq(notebook.all_entries().size(), 1, "entrada repetida nao deveria ser adicionada")


func test_add_entry_rejects_null_and_empty_id() -> void:
	var notebook := Notebook.new()
	assert_false(notebook.add_entry(null), "add_entry(null) deveria devolver false")
	assert_false(notebook.add_entry(_make_entry("", NotebookEntry.Category.CURFEW, "centro")),
		"entrada sem id deveria ser rejeitada")
	assert_eq(notebook.all_entries().size(), 0, "nada deveria ter sido adicionado")


func test_add_entries_returns_how_many_were_added() -> void:
	var notebook := Notebook.new()
	var entries: Array[NotebookEntry] = [
		_make_entry("e1", NotebookEntry.Category.CURFEW, "centro"),
		_make_entry("e2", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora"),
		_make_entry("e1", NotebookEntry.Category.DETAINED, "centro"),
	]
	assert_eq(notebook.add_entries(entries), 2, "so as 2 entradas de id novo deveriam entrar")
	assert_eq(notebook.all_entries().size(), 2, "caderno deveria ter 2 entradas")


func test_all_entries_returns_a_copy() -> void:
	var notebook := Notebook.new()
	notebook.add_entry(_make_entry("e1", NotebookEntry.Category.CURFEW, "centro"))
	var entries := notebook.all_entries()
	entries.clear()
	assert_eq(notebook.all_entries().size(), 1, "mexer no array devolvido nao deveria mexer no caderno")


func test_entries_in_category_filters_by_category() -> void:
	var notebook := Notebook.new()
	notebook.add_entry(_make_entry("e1", NotebookEntry.Category.FORBIDDEN_WORD, "greve"))
	notebook.add_entry(_make_entry("e2", NotebookEntry.Category.FORBIDDEN_WORD, "desaparecido"))
	notebook.add_entry(_make_entry("e3", NotebookEntry.Category.CURFEW, "centro"))

	var found := notebook.entries_in_category(NotebookEntry.Category.FORBIDDEN_WORD)
	assert_eq(found.size(), 2, "deveria achar as 2 palavras proibidas")


func test_entries_for_key_filters_by_key() -> void:
	var notebook := Notebook.new()
	notebook.add_entry(_make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora"))
	notebook.add_entry(_make_entry("e2", NotebookEntry.Category.CURFEW, "rua_aurora"))
	notebook.add_entry(_make_entry("e3", NotebookEntry.Category.CURFEW, "centro"))

	assert_eq(notebook.entries_for_key("rua_aurora").size(), 2, "deveria achar as 2 da Rua Aurora")
	assert_eq(notebook.entries_for_key("inexistente").size(), 0, "chave desconhecida nao deveria achar nada")


func test_find_entry_returns_null_when_unknown() -> void:
	var notebook := Notebook.new()
	notebook.add_entry(_make_entry("e1", NotebookEntry.Category.CURFEW, "centro"))
	assert_not_null(notebook.find_entry("e1"), "deveria achar a entrada existente")
	assert_null(notebook.find_entry("nao_existe"), "id desconhecido deveria devolver null")


func test_forbidden_words_lists_only_forbidden_word_keys() -> void:
	var notebook := Notebook.new()
	notebook.add_entry(_make_entry("e1", NotebookEntry.Category.FORBIDDEN_WORD, "greve"))
	notebook.add_entry(_make_entry("e2", NotebookEntry.Category.CURFEW, "centro"))
	notebook.add_entry(_make_entry("e3", NotebookEntry.Category.FORBIDDEN_WORD, "desaparecido"))

	var words := notebook.forbidden_words()
	assert_eq(words.size(), 2, "deveria listar 2 palavras proibidas")
	assert_true(words.has("greve"), "deveria conter 'greve'")
	assert_true(words.has("desaparecido"), "deveria conter 'desaparecido'")
	assert_false(words.has("centro"), "nao deveria conter chave de outra categoria")


func test_notebook_only_grows() -> void:
	var notebook := Notebook.new()
	assert_false(notebook.has_method("remove_entry"), "o caderno nao deveria ter como remover entradas")
	assert_false(notebook.has_method("clear"), "o caderno nao deveria ter como ser esvaziado")
