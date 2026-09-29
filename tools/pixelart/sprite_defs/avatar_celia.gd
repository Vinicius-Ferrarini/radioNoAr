extends RefCounted

## Dona Célia. Foto tirada de perto demais, com a lâmpada atrás: dá para
## ver o coque e o ombro, não o rosto.

static func definition() -> Dictionary:
	return {
		"name": "avatar_celia",
		"size": Vector2i(16, 16),
		"legend": {
			".": "night_deep",
			"b": "street_blue",
			"s": "shadow",
			"a": "amber_dim",
			"h": "amber_mid",
		},
		"rows": PackedStringArray([
			"....hhhh........",
			"...hhaahh.......",
			"..hhaaaahh......",
			"..haasssahh.....",
			"..hasssssah.....",
			"..hasssssah.....",
			"...asssssa......",
			"...assssaa......",
			"....ssssa.......",
			"....ssss........",
			"...sssssss......",
			"..sssssssss.....",
			".sssssssssss....",
			".sssssssssss....",
			"bsssssssssssb...",
			"bbsssssssssbb...",
		]),
	}
