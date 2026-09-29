class_name BroadcastItem
extends Resource

## Um item que chegou para a triagem da noite.

enum ItemType {
	BRIBE,
	VENDOR,
	REVENGE,
	SPOTLIGHT,
	HELP_REQUEST,
	PROPAGANDA,
}

enum Channel {
	PHONE,
	LETTER,
	CALL,
	OFFICIAL,
}

@export var id: String
@export var type: ItemType
@export var channel: Channel
@export var sender_id: String
@export var headline: String
## O texto como chegou, sem enquadramento.
@export var body: String
@export var claims: Array[ItemClaim]
@export var framings: Array[FramingOption]
## Conta para a cota de propaganda do programa.
@export var counts_for_quota: bool
## Verdade de bastidor: nunca exibida ao jogador, nunca lida pelo
## Validator. So a fase de manha cruza isto com o que o jogador marcou.
@export var is_fraudulent: bool
