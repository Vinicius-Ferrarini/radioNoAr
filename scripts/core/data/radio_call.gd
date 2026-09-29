class_name RadioCall
extends Resource

## Uma ligação roteirizada; a lógica controla o prazo, não a cena.
@export var caller: String
@export_multiline var transcript: String
@export var trigger_seconds: float = 3.0
## Em que bloco do programa ela entra. Além do último, cai no último.
@export var block_position: int = 1
@export_multiline var aired_reaction: String
@export_multiline var cut_reaction: String
@export var aired_consequence_ids: Array[String]
@export var cut_consequence_ids: Array[String]
