class_name FramingOption
extends Resource

## Como um item vai ao ar. IRONY so e valido para itens PROPAGANDA.

enum Kind {
	AS_RECEIVED,
	TRUTH,
	SOFTEN,
	INFLAME,
	IRONY,
	DISCARD,
}

@export var kind: Kind
## BroadcastScript usado no teleprompter (M9).
@export var script_id: String
## meter_id -> int. Só medidores visiveis reagem ao vivo.
@export var immediate_deltas: Dictionary
## Ids de ConsequenceEffect agendados para a manha seguinte.
@export var consequence_ids: Array[String]
