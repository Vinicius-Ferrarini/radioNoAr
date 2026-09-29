class_name NotebookEntry
extends Resource

## Uma linha do caderno do apresentador. O caderno so cresce.

enum Category {
	FORBIDDEN_WORD,
	EVACUATED_AREA,
	CURFEW,
	KNOWN_INFORMANT,
	DETAINED,
	DISAPPEARED,
	LIAR_SENDER,
	RESISTANCE_CODE,
}

@export var id: String
@export var category: Category
## Chave normalizada que casa com ItemClaim.key.
@export var key: String
## Como a entrada aparece escrita no caderno.
@export var text: String
@export var night_added: int
