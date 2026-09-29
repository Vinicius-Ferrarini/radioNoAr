extends GutTest


func _make_item(id: String, type: int, quota := false) -> BroadcastItem:
	var item := BroadcastItem.new()
	item.id = id
	item.type = type
	item.channel = BroadcastItem.Channel.PHONE
	item.sender_id = "remetente_%s" % id
	item.headline = "manchete"
	item.body = "corpo"
	item.counts_for_quota = quota

	var framings: Array[FramingOption] = []
	for kind in [FramingOption.Kind.AS_RECEIVED, FramingOption.Kind.TRUTH, FramingOption.Kind.DISCARD]:
		var framing := FramingOption.new()
		framing.kind = kind
		framings.append(framing)
	item.framings = framings
	return item


func _make_rule(previous_type: int, next_type: int, deltas: Dictionary) -> OrderRule:
	var rule := OrderRule.new()
	rule.id = "rule_%d_%d" % [previous_type, next_type]
	rule.previous_type = previous_type
	rule.next_type = next_type
	rule.meter_deltas = deltas
	rule.description = "regra de teste"
	return rule


func _empty_rundown(quota := 1) -> ProgramRundown:
	return ProgramRundown.new(quota, [] as Array[OrderRule])


# --- colocar itens nos blocos ---

func test_place_puts_the_item_in_the_block() -> void:
	var rundown := _empty_rundown()
	var item := _make_item("i1", BroadcastItem.ItemType.SPOTLIGHT)
	assert_eq(rundown.place(item, 0), ProgramRundown.PlaceResult.OK)
	assert_eq(rundown.item_at(0), item)
	assert_eq(rundown.filled_blocks(), 1)


func test_place_rejects_invalid_block_index() -> void:
	var rundown := _empty_rundown()
	var item := _make_item("i1", BroadcastItem.ItemType.SPOTLIGHT)
	assert_eq(rundown.place(item, -1), ProgramRundown.PlaceResult.INVALID_BLOCK)
	assert_eq(rundown.place(item, ProgramRundown.BLOCK_COUNT), ProgramRundown.PlaceResult.INVALID_BLOCK)
	assert_eq(rundown.filled_blocks(), 0)


func test_place_rejects_an_occupied_block() -> void:
	var rundown := _empty_rundown()
	rundown.place(_make_item("i1", BroadcastItem.ItemType.SPOTLIGHT), 0)
	assert_eq(rundown.place(_make_item("i2", BroadcastItem.ItemType.REVENGE), 0),
		ProgramRundown.PlaceResult.BLOCK_TAKEN)
	assert_eq(rundown.item_at(0).id, "i1", "o bloco deveria continuar com o item original")


func test_place_rejects_an_item_already_in_the_program() -> void:
	var rundown := _empty_rundown()
	var item := _make_item("i1", BroadcastItem.ItemType.SPOTLIGHT)
	rundown.place(item, 0)
	assert_eq(rundown.place(item, 1), ProgramRundown.PlaceResult.ITEM_ALREADY_PLACED)
	assert_eq(rundown.filled_blocks(), 1)


func test_clear_block_frees_the_item() -> void:
	var rundown := _empty_rundown()
	var item := _make_item("i1", BroadcastItem.ItemType.SPOTLIGHT)
	rundown.place(item, 0)
	rundown.clear_block(0)
	assert_null(rundown.item_at(0))
	assert_eq(rundown.place(item, 2), ProgramRundown.PlaceResult.OK,
		"depois de tirado, o item pode voltar em outro bloco")


# --- mover ---

func test_move_to_an_empty_block() -> void:
	var rundown := _empty_rundown()
	var item := _make_item("i1", BroadcastItem.ItemType.SPOTLIGHT)
	rundown.place(item, 0)
	assert_eq(rundown.move(0, 3), ProgramRundown.PlaceResult.OK)
	assert_null(rundown.item_at(0))
	assert_eq(rundown.item_at(3), item)


func test_move_to_an_occupied_block_swaps_the_two() -> void:
	var rundown := _empty_rundown()
	var first := _make_item("i1", BroadcastItem.ItemType.SPOTLIGHT)
	var second := _make_item("i2", BroadcastItem.ItemType.REVENGE)
	rundown.place(first, 0)
	rundown.place(second, 1)

	assert_eq(rundown.move(0, 1), ProgramRundown.PlaceResult.OK)
	assert_eq(rundown.item_at(0), second, "os dois itens deveriam ter trocado de lugar")
	assert_eq(rundown.item_at(1), first)


func test_move_keeps_the_framing_with_its_item() -> void:
	var rundown := _empty_rundown()
	rundown.place(_make_item("i1", BroadcastItem.ItemType.SPOTLIGHT), 0)
	rundown.place(_make_item("i2", BroadcastItem.ItemType.REVENGE), 1)
	rundown.set_framing(0, FramingOption.Kind.TRUTH)
	rundown.set_framing(1, FramingOption.Kind.AS_RECEIVED)

	rundown.move(0, 1)
	assert_eq(rundown.framing_at(1), FramingOption.Kind.TRUTH,
		"o enquadramento deveria seguir o item, nao o bloco")
	assert_eq(rundown.framing_at(0), FramingOption.Kind.AS_RECEIVED)


func test_move_rejects_invalid_indexes_and_empty_origin() -> void:
	var rundown := _empty_rundown()
	rundown.place(_make_item("i1", BroadcastItem.ItemType.SPOTLIGHT), 0)
	assert_eq(rundown.move(0, 9), ProgramRundown.PlaceResult.INVALID_BLOCK)
	assert_eq(rundown.move(2, 3), ProgramRundown.PlaceResult.INVALID_BLOCK,
		"mover um bloco vazio nao faz sentido")


# --- enquadramento ---

func test_set_framing_rejects_a_kind_the_item_does_not_allow() -> void:
	var rundown := _empty_rundown()
	rundown.place(_make_item("i1", BroadcastItem.ItemType.SPOTLIGHT), 0)
	assert_eq(rundown.set_framing(0, FramingOption.Kind.IRONY),
		ProgramRundown.PlaceResult.FRAMING_NOT_ALLOWED)
	assert_eq(rundown.framing_at(0), -1, "enquadramento invalido nao deveria ser guardado")


func test_set_framing_on_an_empty_block_is_invalid() -> void:
	var rundown := _empty_rundown()
	assert_eq(rundown.set_framing(0, FramingOption.Kind.TRUTH), ProgramRundown.PlaceResult.INVALID_BLOCK)


func test_framing_starts_unset() -> void:
	var rundown := _empty_rundown()
	rundown.place(_make_item("i1", BroadcastItem.ItemType.SPOTLIGHT), 0)
	assert_eq(rundown.framing_at(0), -1)


# --- cota ---

func test_quota_counts_only_official_items() -> void:
	var rundown := _empty_rundown(2)
	rundown.place(_make_item("oficial_1", BroadcastItem.ItemType.PROPAGANDA, true), 0)
	rundown.place(_make_item("povo", BroadcastItem.ItemType.SPOTLIGHT), 1)

	assert_eq(rundown.quota_required(), 2)
	assert_eq(rundown.quota_filled(), 1)
	assert_false(rundown.quota_met())

	rundown.place(_make_item("oficial_2", BroadcastItem.ItemType.PROPAGANDA, true), 2)
	assert_eq(rundown.quota_filled(), 2)
	assert_true(rundown.quota_met())


func test_quota_of_three_needs_three_official_blocks() -> void:
	var rundown := _empty_rundown(3)
	for i in 3:
		rundown.place(_make_item("oficial_%d" % i, BroadcastItem.ItemType.PROPAGANDA, true), i)
	assert_true(rundown.quota_met())


func test_a_discarded_official_item_does_not_count_for_the_quota() -> void:
	var rundown := _empty_rundown(1)
	rundown.place(_make_item("oficial", BroadcastItem.ItemType.PROPAGANDA, true), 0)
	rundown.set_framing(0, FramingOption.Kind.DISCARD)
	assert_eq(rundown.quota_filled(), 0, "descartar no ar nao cumpre a cota")
	assert_false(rundown.quota_met())


# --- pronto para ir ao ar ---

func test_is_ready_requires_every_block_with_item_and_framing() -> void:
	var rundown := _empty_rundown()
	for i in ProgramRundown.BLOCK_COUNT:
		rundown.place(_make_item("i%d" % i, BroadcastItem.ItemType.SPOTLIGHT), i)
	assert_false(rundown.is_ready(), "falta escolher os enquadramentos")

	for i in ProgramRundown.BLOCK_COUNT:
		rundown.set_framing(i, FramingOption.Kind.TRUTH)
	assert_true(rundown.is_ready())


func test_is_ready_does_not_require_the_quota() -> void:
	var rundown := _empty_rundown(4)
	for i in ProgramRundown.BLOCK_COUNT:
		rundown.place(_make_item("i%d" % i, BroadcastItem.ItemType.SPOTLIGHT), i)
		rundown.set_framing(i, FramingOption.Kind.TRUTH)

	assert_false(rundown.quota_met(), "a cota nao foi cumprida")
	assert_true(rundown.is_ready(), "recusar a cota e uma escolha, nao um impedimento")


# --- efeitos de ordem ---

func test_order_effects_matches_propaganda_after_a_denunciation() -> void:
	var rules: Array[OrderRule] = [
		_make_rule(BroadcastItem.ItemType.REVENGE, BroadcastItem.ItemType.PROPAGANDA,
			{Meters.AUDIENCE_TRUST: 4}),
	]
	var rundown := ProgramRundown.new(1, rules)
	rundown.place(_make_item("denuncia", BroadcastItem.ItemType.REVENGE), 0)
	rundown.place(_make_item("oficial", BroadcastItem.ItemType.PROPAGANDA, true), 1)

	var effects := rundown.order_effects()
	assert_eq(effects.size(), 1, "a regra deveria casar")
	assert_eq(effects[0].meter_deltas[Meters.AUDIENCE_TRUST], 4)


func test_order_effects_does_not_match_the_reverse_order() -> void:
	var rules: Array[OrderRule] = [
		_make_rule(BroadcastItem.ItemType.REVENGE, BroadcastItem.ItemType.PROPAGANDA,
			{Meters.AUDIENCE_TRUST: 4}),
	]
	var rundown := ProgramRundown.new(1, rules)
	rundown.place(_make_item("oficial", BroadcastItem.ItemType.PROPAGANDA, true), 0)
	rundown.place(_make_item("denuncia", BroadcastItem.ItemType.REVENGE), 1)

	assert_eq(rundown.order_effects().size(), 0, "a ordem inversa nao e a mesma coisa")


func test_order_effects_only_looks_at_consecutive_blocks() -> void:
	var rules: Array[OrderRule] = [
		_make_rule(BroadcastItem.ItemType.REVENGE, BroadcastItem.ItemType.PROPAGANDA,
			{Meters.AUDIENCE_TRUST: 4}),
	]
	var rundown := ProgramRundown.new(1, rules)
	rundown.place(_make_item("denuncia", BroadcastItem.ItemType.REVENGE), 0)
	rundown.place(_make_item("meio", BroadcastItem.ItemType.SPOTLIGHT), 1)
	rundown.place(_make_item("oficial", BroadcastItem.ItemType.PROPAGANDA, true), 2)

	assert_eq(rundown.order_effects().size(), 0, "com um bloco no meio nao ha adjacencia")


func test_order_effects_accepts_wildcards() -> void:
	var rules: Array[OrderRule] = [
		_make_rule(OrderRule.ANY_TYPE, BroadcastItem.ItemType.PROPAGANDA, {Meters.ALIGNMENT: 2}),
	]
	var rundown := ProgramRundown.new(1, rules)
	rundown.place(_make_item("qualquer", BroadcastItem.ItemType.HELP_REQUEST), 0)
	rundown.place(_make_item("oficial", BroadcastItem.ItemType.PROPAGANDA, true), 1)

	assert_eq(rundown.order_effects().size(), 1, "-1 deveria casar com qualquer tipo")


func test_order_effects_ignores_discarded_blocks() -> void:
	var rules: Array[OrderRule] = [
		_make_rule(BroadcastItem.ItemType.REVENGE, BroadcastItem.ItemType.PROPAGANDA,
			{Meters.AUDIENCE_TRUST: 4}),
	]
	var rundown := ProgramRundown.new(1, rules)
	rundown.place(_make_item("denuncia", BroadcastItem.ItemType.REVENGE), 0)
	rundown.place(_make_item("oficial", BroadcastItem.ItemType.PROPAGANDA, true), 1)
	rundown.set_framing(0, FramingOption.Kind.DISCARD)

	assert_eq(rundown.order_effects().size(), 0,
		"um item descartado nao vai ao ar, entao nao ha adjacencia no ar")


func test_aired_items_skips_discarded_ones() -> void:
	var rundown := _empty_rundown()
	rundown.place(_make_item("vai", BroadcastItem.ItemType.SPOTLIGHT), 0)
	rundown.place(_make_item("nao_vai", BroadcastItem.ItemType.REVENGE), 1)
	rundown.set_framing(0, FramingOption.Kind.TRUTH)
	rundown.set_framing(1, FramingOption.Kind.DISCARD)

	var aired := rundown.aired_items()
	assert_eq(aired.size(), 1)
	assert_eq(aired[0].id, "vai")
