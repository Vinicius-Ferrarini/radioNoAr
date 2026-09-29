extends RefCounted

## J. Toledo. Foto de documento, de frente, mal enquadrada. O queixo
## aparece, os olhos ficam na sombra da testa.

static func definition() -> Dictionary:
	return {
		"name": "avatar_toledo",
		"size": Vector2i(16, 16),
		"legend": {
			".": "night_deep",
			"b": "street_blue",
			"s": "shadow",
			"d": "desk_dark",
			"a": "amber_dim",
		},
		"rows": PackedStringArray([
			"................",
			"....ssssss......",
			"...sddddddss....",
			"...sdaaaadds....",
			"...sdaaaaads....",
			"...ssaaaaass....",
			"...sdaaaaads....",
			"....daaaaad.....",
			"....ddaaadd.....",
			".....dddddd.....",
			"....ssdddss.....",
			"...sssddsss.....",
			"..bsssddssssb...",
			".bbsssssssssbb..",
			".bbsssssssssbb..",
			"bbbsssssssssbbb.",
		]),
	}
