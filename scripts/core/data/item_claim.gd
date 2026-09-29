class_name ItemClaim
extends Resource

## Uma afirmacao conferivel dentro de um BroadcastItem.
## O jogador liga o trecho a uma entrada do caderno; quem julga o
## resultado e o Validator, nunca este recurso.

enum Field {
	PLACE,
	DATE,
	NAME,
	NUMBER,
	STAMP,
	SEAL,
	HANDWRITING,
	PHOTO,
	SENDER_HISTORY,
	CODE,
}

@export var id: String
@export var field: Field
## Chave normalizada que casa com NotebookEntry.key (ex.: "rua_aurora").
@export var key: String
## Trecho do item mostrado ao jogador na hora de cruzar.
@export var excerpt: String
## Valores de NotebookEntry.Category que contradizem esta afirmacao.
## E Array[int] porque @export nao aceita array tipado por enum de
## outra classe (SPEC secao 3).
@export var contradicted_by: Array[int]
