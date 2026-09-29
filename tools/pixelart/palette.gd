class_name PixelPalette
extends RefCounted

## A paleta do jogo. Nenhuma definição de sprite escreve cor literal:
## tudo passa por aqui, e o teste de manifesto reprova qualquer pixel
## que não seja uma destas cores.
##
## A ideia: o estúdio é âmbar quente (lâmpada, válvulas) e a rua é azul
## frio. Conforme o cerco aperta, a cor se esvai (ADR 0008).

const HEX := {
	# Sombra e madeira da mesa
	"ink": "12100e",
	"shadow": "1d1a17",
	"desk_dark": "2b241d",
	"desk_mid": "3c3126",
	"desk_hi": "55442f",

	# O âmbar do estúdio
	"amber_dim": "8a5a22",
	"amber_mid": "c8862c",
	"amber_hi": "f0b552",
	"glow": "ffe0a3",

	# Papel: cartas, caderno, roteiro
	"paper": "e8e4da",
	"paper_shade": "c3bdae",
	"paper_dark": "8f8877",

	# A rua, pela janela
	"night_deep": "0b1220",
	"night_blue": "16243a",
	"street_blue": "2d4566",
	"street_hi": "4a6f9e",
	"cold_glow": "9ec4e8",

	# O vermelho do painel: NO AR, corte, alarme
	"red_dim": "7a2a22",
	"red_hi": "b23a2f",
}

## Para onde cada cor escorre quando o cerco aperta. Sempre para outra
## cor da própria paleta: o mundo esfria, não ganha tinta nova.
const FADED := {
	"amber_dim": "desk_mid",
	"amber_mid": "desk_hi",
	"amber_hi": "paper_dark",
	"glow": "paper_shade",
	"paper": "paper_shade",
	"paper_shade": "paper_dark",
	"desk_hi": "desk_mid",
	"desk_mid": "desk_dark",
	"red_hi": "red_dim",
	"red_dim": "shadow",
	"street_hi": "street_blue",
	"cold_glow": "street_hi",
}

## Transparente. Usado como "sem cor" nas definições de sprite.
const NONE := ""


static func has_color(color_name: String) -> bool:
	return HEX.has(color_name)


static func get_color(color_name: String) -> Color:
	if color_name == NONE or not HEX.has(color_name):
		return Color(0, 0, 0, 0)
	return Color.html(HEX[color_name])


## Nome da versão esvaída, ou o próprio nome quando a cor não desbota.
static func faded_name(color_name: String) -> String:
	return FADED.get(color_name, color_name)


static func all_names() -> PackedStringArray:
	var names := PackedStringArray(HEX.keys())
	names.sort()
	return names


## Chave estável de uma cor, para comparar pixel de PNG com a paleta sem
## depender de igualdade de float.
static func color_key(color: Color) -> String:
	return "%02x%02x%02x" % [color.r8, color.g8, color.b8]


static func all_color_keys() -> PackedStringArray:
	var keys := PackedStringArray()
	for color_name in HEX:
		keys.append(HEX[color_name])
	return keys
