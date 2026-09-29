class_name ContentLibrary
extends RefCounted

## O unico lugar que sabe onde mora cada arquivo de conteudo.
## Existe para que a logica referencie conteudo por id, nunca por
## caminho, e para que o teste de sanidade do M13 use o mesmo mapa.
##
## Tudo aqui devolve null quando o id nao existe: quem reclama e o teste
## de conteudo, nao o tempo de execucao.

const NIGHTS_DIR := "res://data/nights/"
const NOTEBOOK_DIR := "res://data/notebook/"
const CONSEQUENCES_DIR := "res://data/consequences/"
const ORDER_RULES_PATH := "res://data/rules/order_rules.tres"


static func night(number: int) -> NightDefinition:
	return _load(NIGHTS_DIR + "night_%02d.tres" % number)


static func notebook_entry(id: String) -> NotebookEntry:
	return _load(NOTEBOOK_DIR + id + ".tres")


static func consequence(id: String) -> ConsequenceEffect:
	return _load(CONSEQUENCES_DIR + id + ".tres")


static func order_rules() -> Array[OrderRule]:
	var rule_set: OrderRuleSet = _load(ORDER_RULES_PATH)
	if rule_set == null:
		return [] as Array[OrderRule]
	return rule_set.rules


static func _load(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	return load(path)
