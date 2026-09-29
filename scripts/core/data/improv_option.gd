class_name ImprovOption
extends Resource

## Uma das frases que o apresentador pode emendar quando o roteiro para.

@export var id: String
@export_multiline var text: String
## FramingOption.Kind — aqui o enquadramento vira fala.
@export var framing_kind: int
## meter_id -> int, aplicado ao vivo (só audiência reage na hora).
@export var immediate_deltas: Dictionary
@export var consequence_ids: Array[String]
