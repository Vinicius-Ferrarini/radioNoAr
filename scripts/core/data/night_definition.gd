class_name NightDefinition
extends Resource

## Uma noite da campanha: o que chega, quanto o regime exige e o que o
## caderno passa a saber.

enum Era {
	## Celular e telefone fixo.
	PHONE,
	## Internet cortada: cartas e telefone fixo.
	LETTERS,
}

@export var night: int
@export var era: Era
## Sempre mais itens do que cabem nos 4 blocos do programa.
@export var inbox: Array[BroadcastItem]
## Minimo de blocos oficiais no programa desta noite.
@export var propaganda_quota: int
## Entradas que o caderno ganha no comeco desta noite.
@export var new_notebook_entries: Array[NotebookEntry]
