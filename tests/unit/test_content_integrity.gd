extends GutTest

# O Meters ignora em silencio uma chave que nao conhece (SPEC 4.1).
# Quem pega o erro de digitacao e este arquivo.

const NIGHT_PATHS := [
	"res://data/nights/night_01.tres",
]
const ORDER_RULES := "res://data/rules/order_rules.tres"


func _assert_meter_keys(deltas: Dictionary, where: String) -> void:
	for key in deltas:
		assert_true(Meters.all_ids().has(key), "medidor desconhecido '%s' em %s" % [key, where])
		assert_true(deltas[key] is int, "delta de '%s' em %s deveria ser int" % [key, where])


func test_framing_deltas_only_use_known_meters() -> void:
	for path in NIGHT_PATHS:
		var night: NightDefinition = load(path)
		for item in night.inbox:
			for framing in item.framings:
				_assert_meter_keys(framing.immediate_deltas, "%s / %s" % [item.id, framing.kind])


func test_consequence_deltas_only_use_known_meters() -> void:
	var dir := DirAccess.open("res://data/consequences/")
	assert_not_null(dir)
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var effect: ConsequenceEffect = load("res://data/consequences/" + file_name)
		_assert_meter_keys(effect.meter_deltas, file_name)


func test_inconsistency_is_never_written_by_content() -> void:
	# Inconsistencia e calculada pelo NightCycle comparando com o
	# historico; conteudo nenhum pode escrever nela direto.
	var checked := 0
	for path in NIGHT_PATHS:
		var night: NightDefinition = load(path)
		for item in night.inbox:
			for framing in item.framings:
				assert_false(framing.immediate_deltas.has(Meters.INCONSISTENCY),
					"inconsistencia nao e efeito de enquadramento: %s" % item.id)
				checked += 1
	assert_gt(checked, 0, "deveria haver enquadramentos para conferir")


func test_discard_framings_have_no_immediate_deltas() -> void:
	# Descarte nao vai ao ar, entao immediate_deltas seriam ignorados em
	# silencio (SPEC 4.8). O peso de descartar se escreve na consequencia.
	for path in NIGHT_PATHS:
		var night: NightDefinition = load(path)
		for item in night.inbox:
			for framing in item.framings:
				if framing.kind == FramingOption.Kind.DISCARD:
					assert_eq(framing.immediate_deltas.size(), 0,
						"descarte de %s nao pode ter delta imediato" % item.id)


func test_every_sender_cited_by_an_item_exists() -> void:
	# sender_id deixou de ser string solta no M8B (ADR 0010): se um item
	# cita alguem que nao existe em data/senders/, o close fica sem nome
	# e sem cara, e o jogo nao avisa.
	for path in NIGHT_PATHS:
		var night: NightDefinition = load(path)
		for item in night.inbox:
			assert_false(item.sender_id.is_empty(), "item %s sem remetente" % item.id)
			var sender := ContentLibrary.sender(item.sender_id)
			assert_not_null(sender, "remetente inexistente: %s (item %s)" % [item.sender_id, item.id])


func test_every_sender_has_a_name_an_avatar_and_a_voice() -> void:
	var dir := DirAccess.open("res://data/senders/")
	assert_not_null(dir, "a pasta de remetentes deveria existir")

	var checked := 0
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var sender: Sender = load("res://data/senders/" + file_name)
		assert_not_null(sender, "remetente deveria carregar: %s" % file_name)
		assert_false(sender.display_name.is_empty(), "%s sem nome" % file_name)
		assert_false(sender.voice.is_empty(),
			"%s sem descricao de voz: quem escrever conteudo precisa saber como essa pessoa fala" % file_name)
		assert_true(ResourceLoader.exists("res://assets/sprites/%s.png" % sender.avatar),
			"avatar inexistente: %s (%s)" % [sender.avatar, file_name])
		checked += 1

	assert_gt(checked, 0, "deveria haver remetentes em disco")


func test_every_item_says_when_it_arrived() -> void:
	for path in NIGHT_PATHS:
		var night: NightDefinition = load(path)
		for item in night.inbox:
			assert_false(item.received_at.is_empty(),
				"item %s sem hora de chegada: o close mostra isso" % item.id)


func test_order_rules_file_loads() -> void:
	var rule_set: OrderRuleSet = load(ORDER_RULES)
	assert_not_null(rule_set, "o arquivo de regras de ordem deveria carregar")
	assert_gt(rule_set.rules.size(), 0, "deveria haver pelo menos uma regra de ordem")


func test_order_rules_are_well_formed() -> void:
	var rule_set: OrderRuleSet = load(ORDER_RULES)
	var seen: Dictionary = {}
	for rule in rule_set.rules:
		assert_false(rule.id.is_empty(), "regra de ordem sem id")
		assert_false(seen.has(rule.id), "id de regra repetido: %s" % rule.id)
		seen[rule.id] = true
		assert_false(rule.description.is_empty(), "regra %s sem descricao" % rule.id)
		_assert_meter_keys(rule.meter_deltas, rule.id)
		assert_between(rule.previous_type, OrderRule.ANY_TYPE, BroadcastItem.ItemType.PROPAGANDA,
			"tipo anterior fora da faixa em %s" % rule.id)
		assert_between(rule.next_type, OrderRule.ANY_TYPE, BroadcastItem.ItemType.PROPAGANDA,
			"tipo seguinte fora da faixa em %s" % rule.id)


func test_the_canonical_denunciation_then_propaganda_rule_exists() -> void:
	var rule_set: OrderRuleSet = load(ORDER_RULES)
	var found := false
	for rule in rule_set.rules:
		if rule.previous_type == BroadcastItem.ItemType.REVENGE \
				and rule.next_type == BroadcastItem.ItemType.PROPAGANDA:
			found = true
	assert_true(found, "propaganda logo depois de denuncia precisa ter regra propria")
