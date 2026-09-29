class_name Validator
extends RefCounted

## Cruza as afirmacoes de um item com o caderno.
##
## Achar contradicao nao prova fraude; nao achar nada nao prova verdade.
## Este modulo so relata o que o cruzamento diz — quem confronta isso com
## a verdade de bastidor do item e a fase de manha.

enum Result {
	## As duas coisas nao falam do mesmo assunto.
	UNRELATED,
	## Falam do mesmo assunto e nao se contradizem.
	CONSISTENT,
	## Falam do mesmo assunto e nao podem ser as duas verdade.
	CONTRADICTION,
}

var _notebook: Notebook
## item_id -> Array[Dictionary] {claim_id, entry_id, result}
var _links: Dictionary = {}
## item_id -> bool
var _suspicious: Dictionary = {}


func _init(notebook: Notebook) -> void:
	_notebook = notebook


static func evaluate(claim: ItemClaim, entry: NotebookEntry) -> Result:
	if claim == null or entry == null:
		return Result.UNRELATED
	if claim.key != entry.key:
		return Result.UNRELATED
	if claim.contradicted_by.has(entry.category):
		return Result.CONTRADICTION
	return Result.CONSISTENT


## Registra que o jogador ligou um trecho do item a uma linha do caderno.
## Ligacao invalida (ids desconhecidos) nao vira historico.
func link(item: BroadcastItem, claim_id: String, entry_id: String) -> Result:
	if item == null:
		return Result.UNRELATED

	var claim := _find_claim(item, claim_id)
	var entry := _notebook.find_entry(entry_id)
	if claim == null or entry == null:
		return Result.UNRELATED

	var result := evaluate(claim, entry)
	_record(item.id, claim_id, entry_id, result)
	return result


func links_for(item_id: String) -> Array[Dictionary]:
	var links: Array[Dictionary] = _links.get(item_id, [] as Array[Dictionary])
	return links.duplicate()


## Ids das afirmacoes do item que ja foram pegas em contradicao.
func contradictions_for(item_id: String) -> Array[String]:
	var found: Array[String] = []
	for link_data in links_for(item_id):
		if link_data["result"] == Result.CONTRADICTION and not found.has(link_data["claim_id"]):
			found.append(link_data["claim_id"])
	return found


func set_suspicious(item_id: String, value: bool) -> void:
	_suspicious[item_id] = value


func is_suspicious(item_id: String) -> bool:
	return _suspicious.get(item_id, false)


func _find_claim(item: BroadcastItem, claim_id: String) -> ItemClaim:
	for claim in item.claims:
		if claim != null and claim.id == claim_id:
			return claim
	return null


func _record(item_id: String, claim_id: String, entry_id: String, result: Result) -> void:
	if not _links.has(item_id):
		_links[item_id] = [] as Array[Dictionary]

	var links: Array[Dictionary] = _links[item_id]
	for link_data in links:
		if link_data["claim_id"] == claim_id and link_data["entry_id"] == entry_id:
			return

	links.append({"claim_id": claim_id, "entry_id": entry_id, "result": result})
