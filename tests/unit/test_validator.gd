extends GutTest


func _make_entry(id: String, category: int, key: String) -> NotebookEntry:
	var entry := NotebookEntry.new()
	entry.id = id
	entry.category = category
	entry.key = key
	entry.text = "texto de %s" % id
	entry.night_added = 1
	return entry


func _make_claim(id: String, field: int, key: String, contradicted_by: Array[int]) -> ItemClaim:
	var claim := ItemClaim.new()
	claim.id = id
	claim.field = field
	claim.key = key
	claim.excerpt = "trecho de %s" % id
	claim.contradicted_by = contradicted_by
	return claim


func _make_item(id: String, claims: Array[ItemClaim], fraudulent := false) -> BroadcastItem:
	var item := BroadcastItem.new()
	item.id = id
	item.type = BroadcastItem.ItemType.REVENGE
	item.channel = BroadcastItem.Channel.PHONE
	item.sender_id = "remetente"
	item.headline = "manchete"
	item.body = "corpo"
	item.claims = claims
	item.is_fraudulent = fraudulent
	return item


func _notebook_with(entries: Array[NotebookEntry]) -> Notebook:
	var notebook := Notebook.new()
	notebook.add_entries(entries)
	return notebook


# --- evaluate (pura) ---

func test_evaluate_returns_unrelated_for_different_keys() -> void:
	var claim := _make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])
	var entry := _make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "centro")
	assert_eq(Validator.evaluate(claim, entry), Validator.Result.UNRELATED,
		"chaves diferentes nao se relacionam")


func test_evaluate_returns_contradiction_when_category_is_listed() -> void:
	var claim := _make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])
	var entry := _make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora")
	assert_eq(Validator.evaluate(claim, entry), Validator.Result.CONTRADICTION,
		"mesma chave + categoria listada = contradicao")


func test_evaluate_returns_consistent_when_category_is_not_listed() -> void:
	var claim := _make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])
	var entry := _make_entry("e1", NotebookEntry.Category.CURFEW, "rua_aurora")
	assert_eq(Validator.evaluate(claim, entry), Validator.Result.CONSISTENT,
		"mesma chave + categoria nao listada = consistente")


func test_evaluate_with_null_arguments_is_unrelated() -> void:
	var claim := _make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])
	assert_eq(Validator.evaluate(null, null), Validator.Result.UNRELATED)
	assert_eq(Validator.evaluate(claim, null), Validator.Result.UNRELATED)
	assert_eq(Validator.evaluate(null, _make_entry("e1", NotebookEntry.Category.CURFEW, "x")),
		Validator.Result.UNRELATED)


# --- link ---

func test_link_records_the_result() -> void:
	var notebook := _notebook_with([_make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora")])
	var validator := Validator.new(notebook)
	var item := _make_item("i1", [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])])

	assert_eq(validator.link(item, "c1", "e1"), Validator.Result.CONTRADICTION)
	assert_eq(validator.links_for("i1").size(), 1, "a ligacao deveria ficar registrada")
	assert_eq(validator.contradictions_for("i1"), ["c1"], "c1 deveria constar como contradicao")


func test_link_with_unknown_ids_records_nothing() -> void:
	var notebook := _notebook_with([_make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora")])
	var validator := Validator.new(notebook)
	var item := _make_item("i1", [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])])

	assert_eq(validator.link(item, "nao_existe", "e1"), Validator.Result.UNRELATED, "claim desconhecida")
	assert_eq(validator.link(item, "c1", "nao_existe"), Validator.Result.UNRELATED, "entrada desconhecida")
	assert_eq(validator.links_for("i1").size(), 0, "ligacao invalida nao deveria virar historico")


func test_linking_the_same_pair_twice_does_not_duplicate() -> void:
	var notebook := _notebook_with([_make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora")])
	var validator := Validator.new(notebook)
	var item := _make_item("i1", [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])])

	validator.link(item, "c1", "e1")
	validator.link(item, "c1", "e1")
	assert_eq(validator.links_for("i1").size(), 1, "o mesmo par nao deveria ser registrado duas vezes")
	assert_eq(validator.contradictions_for("i1").size(), 1, "contradicao nao deveria duplicar")


func test_contradictions_for_unknown_item_is_empty() -> void:
	var validator := Validator.new(_notebook_with([]))
	assert_eq(validator.contradictions_for("nunca_visto").size(), 0)
	assert_eq(validator.links_for("nunca_visto").size(), 0)


func test_consistent_link_is_recorded_but_is_not_a_contradiction() -> void:
	var notebook := _notebook_with([_make_entry("e1", NotebookEntry.Category.CURFEW, "rua_aurora")])
	var validator := Validator.new(notebook)
	var item := _make_item("i1", [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])])

	assert_eq(validator.link(item, "c1", "e1"), Validator.Result.CONSISTENT)
	assert_eq(validator.links_for("i1").size(), 1, "ligacao valida fica no historico")
	assert_eq(validator.contradictions_for("i1").size(), 0, "consistente nao e contradicao")


# --- suspeita ---

func test_items_start_not_suspicious_and_can_be_toggled() -> void:
	var validator := Validator.new(_notebook_with([]))
	assert_false(validator.is_suspicious("i1"), "item comeca sem suspeita")
	validator.set_suspicious("i1", true)
	assert_true(validator.is_suspicious("i1"))
	validator.set_suspicious("i1", false)
	assert_false(validator.is_suspicious("i1"))


# --- invariantes do design ---

func test_fraudulent_item_without_notebook_entry_shows_no_contradiction() -> void:
	# O caderno nao sabe nada sobre a Rua Aurora nesta noite: a mentira passa.
	var notebook := _notebook_with([_make_entry("e1", NotebookEntry.Category.CURFEW, "centro")])
	var validator := Validator.new(notebook)
	var item := _make_item("i1", [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])], true)

	assert_eq(validator.link(item, "c1", "e1"), Validator.Result.UNRELATED)
	assert_eq(validator.contradictions_for("i1").size(), 0,
		"nao achar contradicao nao pode depender de o item ser falso")


func test_validator_ignores_is_fraudulent_completely() -> void:
	var entries: Array[NotebookEntry] = [_make_entry("e1", NotebookEntry.Category.EVACUATED_AREA, "rua_aurora")]
	var honest := Validator.new(_notebook_with(entries))
	var lying := Validator.new(_notebook_with(entries))

	var claims_honest: Array[ItemClaim] = [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])]
	var claims_lying: Array[ItemClaim] = [_make_claim("c1", ItemClaim.Field.PLACE, "rua_aurora", [NotebookEntry.Category.EVACUATED_AREA])]

	var result_honest: int = honest.link(_make_item("i1", claims_honest, false), "c1", "e1")
	var result_lying: int = lying.link(_make_item("i1", claims_lying, true), "c1", "e1")

	assert_eq(result_honest, result_lying,
		"item verdadeiro e item falso com as mesmas afirmacoes devem dar o mesmo resultado")


func test_validator_source_never_mentions_is_fraudulent() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/core/validator.gd")
	assert_false(source.is_empty(), "validator.gd deveria existir e ser legivel")
	assert_false(source.contains("is_fraudulent"),
		"o Validator nunca pode ler a verdade de bastidor do item")
