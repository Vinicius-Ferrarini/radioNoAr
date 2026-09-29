extends PanelContainer

## Um balão da conversa. Sabe de que lado fica, o que diz e a hora — nada
## mais: quem decide o que aparece é a mesa (ADR 0013).
##
## É PanelContainer e não NinePatchRect porque o balão tem de crescer com
## o texto. Com altura fixa, mensagem de duas linhas vazava por cima da
## seguinte, que foi o defeito relatado no primeiro playtest do celular.

@export var them_style: StyleBox
@export var me_style: StyleBox

@onready var _text: Label = $Lines/Text
@onready var _at: Label = $Lines/At


func setup(message_text: String, from_me: bool, at: String, max_width: float) -> void:
	_text.text = message_text
	_at.text = at
	_at.visible = not at.is_empty()
	add_theme_stylebox_override("panel", me_style if from_me else them_style)
	# O balão não atravessa a tela: some largura ele para de crescer e o
	# texto quebra, como em qualquer aplicativo de mensagem.
	custom_minimum_size = Vector2(0, 0)
	size_flags_horizontal = Control.SIZE_SHRINK_END if from_me else Control.SIZE_SHRINK_BEGIN
	_text.custom_minimum_size = Vector2(0, 0)
	_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text.max_lines_visible = -1
	_apply_width(max_width)


## Largura máxima em pixels. O Label mede o texto e diz de quantas linhas
## precisa; o container acompanha.
func _apply_width(max_width: float) -> void:
	var font := _text.get_theme_font("font")
	var size := _text.get_theme_font_size("font_size")
	var measured := font.get_string_size(_text.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	custom_minimum_size.x = minf(measured + 10.0, max_width)
