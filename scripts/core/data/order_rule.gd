class_name OrderRule
extends Resource

## Efeito de adjacencia entre dois blocos consecutivos do programa.
## "Propaganda logo depois de uma denuncia soa como ironia."

## Casa com qualquer BroadcastItem.ItemType.
const ANY_TYPE := -1

@export var id: String
## BroadcastItem.ItemType do bloco anterior, ou ANY_TYPE.
@export var previous_type: int = ANY_TYPE
## BroadcastItem.ItemType do bloco seguinte, ou ANY_TYPE.
@export var next_type: int = ANY_TYPE
## meter_id -> int
@export var meter_deltas: Dictionary
@export var consequence_ids: Array[String]
## Por que esta regra existe. Aparece em revisao de conteudo, nao no jogo.
@export var description: String
