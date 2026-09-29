class_name ConsequenceEffect
extends Resource

## O preco de uma noite, cobrado na manha seguinte. Nunca na mesma noite:
## delay_nights e sempre tratado como no minimo 1 pela ConsequenceQueue.

enum Condition {
	## Sempre acontece.
	ALWAYS,
	## So se o item era falso e mesmo assim foi ao ar.
	FRAUD_AIRED,
	## So se o item era falso e o jogador o marcou como suspeito.
	FRAUD_CAUGHT,
}

@export var id: String
@export var delay_nights: int = 1
@export var condition: Condition
## meter_id -> int
@export var meter_deltas: Dictionary
@export var resource_deltas: Dictionary
## O que o jogador le de manha. Pode ser ambiguo de proposito.
@export_multiline var morning_headline: String
@export_multiline var morning_letter: String
## Entradas que a manha acrescenta ao caderno.
@export var notebook_entry_ids: Array[String]
## Marcas narrativas lidas pelo EndingResolver (M12).
@export var flags_set: Array[String]
