class_name ProgramRundown
extends RefCounted

## Os 4 blocos do programa da noite. A ordem importa: propaganda logo
## depois de uma denuncia soa como ironia.

const BLOCK_COUNT := 4
## Ainda sem enquadramento escolhido.
const NO_FRAMING := -1

enum PlaceResult {
	OK,
	INVALID_BLOCK,
	BLOCK_TAKEN,
	ITEM_ALREADY_PLACED,
	FRAMING_NOT_ALLOWED,
}

var _quota: int
var _validator: Validator
var _rules: Array[OrderRule] = []
var _items: Array[BroadcastItem] = []
var _framings: Array[int] = []


func _init(propaganda_quota: int, order_rules: Array[OrderRule], validator: Validator = null) -> void:
	_quota = propaganda_quota
	_validator = validator
	_rules = order_rules
	for i in BLOCK_COUNT:
		_items.append(null)
		_framings.append(NO_FRAMING)


func place(item: BroadcastItem, block_index: int) -> PlaceResult:
	if item == null or not _is_valid_block(block_index):
		return PlaceResult.INVALID_BLOCK
	if _items[block_index] != null:
		return PlaceResult.BLOCK_TAKEN
	if _block_of(item) != -1:
		return PlaceResult.ITEM_ALREADY_PLACED

	_items[block_index] = item
	_framings[block_index] = NO_FRAMING
	return PlaceResult.OK


## Mover para um bloco ocupado troca os dois. O enquadramento acompanha
## o item, nao o bloco.
func move(from_index: int, to_index: int) -> PlaceResult:
	if not _is_valid_block(from_index) or not _is_valid_block(to_index):
		return PlaceResult.INVALID_BLOCK
	if _items[from_index] == null:
		return PlaceResult.INVALID_BLOCK

	var item := _items[from_index]
	var framing := _framings[from_index]

	_items[from_index] = _items[to_index]
	_framings[from_index] = _framings[to_index]
	_items[to_index] = item
	_framings[to_index] = framing
	return PlaceResult.OK


func clear_block(block_index: int) -> void:
	if not _is_valid_block(block_index):
		return
	_items[block_index] = null
	_framings[block_index] = NO_FRAMING


func item_at(block_index: int) -> BroadcastItem:
	if not _is_valid_block(block_index):
		return null
	return _items[block_index]


func set_framing(block_index: int, kind: int) -> PlaceResult:
	if not _is_valid_block(block_index) or _items[block_index] == null:
		return PlaceResult.INVALID_BLOCK
	if not _allows_framing(_items[block_index], kind):
		return PlaceResult.FRAMING_NOT_ALLOWED

	_framings[block_index] = kind
	return PlaceResult.OK


func framing_at(block_index: int) -> int:
	if not _is_valid_block(block_index):
		return NO_FRAMING
	return _framings[block_index]


func filled_blocks() -> int:
	var filled := 0
	for item in _items:
		if item != null:
			filled += 1
	return filled


func quota_required() -> int:
	return _quota


## So conta o que vai ao ar: descartar um comunicado nao cumpre a cota.
func quota_filled() -> int:
	var filled := 0
	for i in BLOCK_COUNT:
		if _goes_on_air(i) and _items[i].counts_for_quota:
			filled += 1
	return filled


func quota_met() -> bool:
	return quota_filled() >= _quota


## Cota nao cumprida nao impede o programa: recusar e escolha do jogador,
## paga em atencao do regime na manha seguinte.
func is_ready() -> bool:
	for i in BLOCK_COUNT:
		if _items[i] == null or _framings[i] == NO_FRAMING:
			return false
	return true


func aired_items() -> Array[BroadcastItem]:
	var aired: Array[BroadcastItem] = []
	for i in BLOCK_COUNT:
		if _goes_on_air(i):
			aired.append(_items[i])
	return aired


## Regras casadas pelos pares de blocos consecutivos que vao ao ar.
func order_effects() -> Array[OrderRule]:
	var effects: Array[OrderRule] = []
	for i in BLOCK_COUNT - 1:
		if not _goes_on_air(i) or not _goes_on_air(i + 1):
			continue
		for rule in _rules:
			if _matches(rule, _items[i].type, _items[i + 1].type):
				effects.append(rule)
	return effects


func _is_valid_block(block_index: int) -> bool:
	return block_index >= 0 and block_index < BLOCK_COUNT


func _block_of(item: BroadcastItem) -> int:
	for i in BLOCK_COUNT:
		if _items[i] == item:
			return i
	return -1


func _allows_framing(item: BroadcastItem, kind: int) -> bool:
	return framing_available(item, kind)


func framing_available(item: BroadcastItem, kind: int) -> bool:
	if item == null:
		return false
	for framing in item.framings:
		if framing != null and framing.kind == kind:
			if framing.required_claim_id.is_empty():
				return true
			if _validator == null:
				return false
			for link in _validator.links_for(item.id):
				if link["claim_id"] == framing.required_claim_id and link["result"] != Validator.Result.UNRELATED:
					return true
	return false


## Um bloco vai ao ar enquanto nao for explicitamente descartado: sem
## enquadramento escolhido, o item ainda esta no programa.
func _goes_on_air(block_index: int) -> bool:
	return _items[block_index] != null \
		and _framings[block_index] != FramingOption.Kind.DISCARD


func _matches(rule: OrderRule, previous_type: int, next_type: int) -> bool:
	var previous_ok: bool = rule.previous_type == OrderRule.ANY_TYPE or rule.previous_type == previous_type
	var next_ok: bool = rule.next_type == OrderRule.ANY_TYPE or rule.next_type == next_type
	return previous_ok and next_ok
