extends GutTest

# Sanidade dos dados de conteudo (ADR 0009). No M5 so existe a noite 1;
# o M13 estende este arquivo para todas as noites da campanha.

const NIGHT_PATHS := [
	"res://data/nights/night_01.tres",
]

# ProgramRundown chega no M6; ate la a contagem de blocos vive aqui.
const BLOCK_COUNT := 4


func _load_night(path: String) -> NightDefinition:
	var night: NightDefinition = load(path)
	assert_not_null(night, "noite deveria carregar: %s" % path)
	return night


func test_every_night_file_loads() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		assert_gt(night.night, 0, "numero da noite deveria ser positivo: %s" % path)


func test_inbox_has_more_items_than_blocks() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		assert_gt(night.inbox.size(), BLOCK_COUNT,
			"a triagem exige mais itens do que cabem no programa: %s" % path)


func test_quota_is_at_least_one() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		assert_gte(night.propaganda_quota, 1, "a cota de propaganda comeca em 1: %s" % path)


func test_every_item_has_required_fields() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		for item in night.inbox:
			assert_false(item.id.is_empty(), "item sem id em %s" % path)
			assert_false(item.headline.is_empty(), "item %s sem headline" % item.id)
			assert_false(item.body.is_empty(), "item %s sem body" % item.id)
			assert_false(item.sender_id.is_empty(), "item %s sem remetente" % item.id)
			assert_gt(item.framings.size(), 0, "item %s sem enquadramentos" % item.id)


func test_item_ids_are_unique_within_a_night() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		var seen: Dictionary = {}
		for item in night.inbox:
			assert_false(seen.has(item.id), "id de item repetido: %s em %s" % [item.id, path])
			seen[item.id] = true


func test_irony_framing_only_exists_on_propaganda() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		for item in night.inbox:
			for framing in item.framings:
				if framing.kind == FramingOption.Kind.IRONY:
					assert_eq(item.type, BroadcastItem.ItemType.PROPAGANDA,
						"so propaganda pode ser ironizada: %s" % item.id)


func test_every_item_can_be_discarded() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		for item in night.inbox:
			var kinds: Array[int] = []
			for framing in item.framings:
				kinds.append(framing.kind)
			assert_true(kinds.has(FramingOption.Kind.DISCARD),
				"todo item precisa poder ser descartado: %s" % item.id)


func test_quota_is_reachable_with_the_items_of_the_night() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		var official := 0
		for item in night.inbox:
			if item.counts_for_quota:
				official += 1
		assert_gte(official, night.propaganda_quota,
			"a noite precisa ter itens oficiais suficientes para a cota: %s" % path)


func test_night_one_has_at_least_one_detectable_fraud() -> void:
	var night := _load_night("res://data/nights/night_01.tres")
	var notebook := Notebook.new()
	notebook.add_entries(night.new_notebook_entries)
	var validator := Validator.new(notebook)

	var detectable := 0
	for item in night.inbox:
		for claim in item.claims:
			for entry in notebook.entries_for_key(claim.key):
				if validator.link(item, claim.id, entry.id) == Validator.Result.CONTRADICTION:
					detectable += 1

	assert_gt(detectable, 0, "a noite 1 precisa de pelo menos 1 fraude detectavel pelo caderno")


func test_night_one_has_an_item_that_no_cross_reference_can_resolve() -> void:
	# O jogador precisa sentir que nao achar nada nao prova nada.
	var night := _load_night("res://data/nights/night_01.tres")
	var notebook := Notebook.new()
	notebook.add_entries(night.new_notebook_entries)

	var undecidable := 0
	for item in night.inbox:
		var has_any_entry := false
		for claim in item.claims:
			if notebook.entries_for_key(claim.key).size() > 0:
				has_any_entry = true
		if not has_any_entry:
			undecidable += 1

	assert_gt(undecidable, 0, "a noite 1 precisa de pelo menos 1 item que o caderno nao alcanca")


func test_every_consequence_referenced_by_a_framing_exists() -> void:
	for path in NIGHT_PATHS:
		var night := _load_night(path)
		for item in night.inbox:
			for framing in item.framings:
				for consequence_id in framing.consequence_ids:
					var consequence_path := "res://data/consequences/%s.tres" % consequence_id
					assert_true(ResourceLoader.exists(consequence_path),
						"consequencia referenciada nao existe: %s (item %s)" % [consequence_path, item.id])


func test_every_consequence_has_delay_of_at_least_one_night() -> void:
	var dir := DirAccess.open("res://data/consequences/")
	assert_not_null(dir, "a pasta de consequencias deveria existir")

	var checked := 0
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var effect: ConsequenceEffect = load("res://data/consequences/" + file_name)
		assert_not_null(effect, "consequencia deveria carregar: %s" % file_name)
		assert_gte(effect.delay_nights, 1,
			"nenhuma consequencia pode chegar na mesma noite: %s" % file_name)
		assert_false(effect.id.is_empty(), "consequencia sem id: %s" % file_name)
		checked += 1

	assert_gt(checked, 0, "deveria haver pelo menos uma consequencia em disco")
