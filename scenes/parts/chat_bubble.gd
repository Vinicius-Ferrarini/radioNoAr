extends NinePatchRect

## Um balão da conversa. Sabe de que lado fica e nada mais: quem decide o
## que aparece é a mesa (ADR 0013).

@export var them_texture: Texture2D
@export var me_texture: Texture2D

@onready var _text: Label = $Text


func setup(message_text: String, from_me: bool, width: float) -> void:
	_text.text = message_text
	texture = me_texture if from_me else them_texture
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if from_me \
		else HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size = Vector2(width, 12)
	# A bolha cresce com o texto; a altura vem do próprio Label.
	_text.custom_minimum_size = Vector2(width - 8, 0)
