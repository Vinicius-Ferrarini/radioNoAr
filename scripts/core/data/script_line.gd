class_name ScriptLine
extends Resource

## Uma linha do teleprompter.

@export_multiline var text: String
## Quanto tempo a linha leva para subir, se o microfone ficar ligado.
@export var read_seconds: float = 4.0
@export var forbidden_slots: Array[ForbiddenWordSlot]
## Nulo quando não há improviso nesta linha.
@export var improv_point: ImprovPoint
