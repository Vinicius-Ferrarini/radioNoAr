class_name ChatMessage
extends Resource

## Uma fala da conversa. Curta de propósito: a thread é lida em balões,
## não em parágrafo (ADR 0013).

@export var from_me: bool = false
@export_multiline var text: String
## Espera desde a fala anterior da mesma rajada: o tempo de a pessoa
## digitar. Quem conta é a lógica pura, por tick(delta) (ADR 0007).
@export var delay_seconds: float = 1.2
## Etiqueta de hora mostrada no balão, tipo "23:14". Só apresentação.
@export var at: String
