extends RefCounted

## Papel de repartição: mais frio que a carta de gente, com a tarja do
## cabeçalho e o furo do arquivo. Dá para reconhecer de longe.

static func definition() -> Dictionary:
	return {
		"name": "official_sheet",
		"size": Vector2i(32, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper_shade"},
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 4, "color": "desk_dark"},
			{"op": "dither", "x": 0, "y": 0, "w": 32, "h": 4, "color": "shadow", "step": 2},
			{"op": "rect", "x": 2, "y": 8, "w": 2, "h": 2, "color": "paper_dark"},
			{"op": "rect", "x": 2, "y": 22, "w": 2, "h": 2, "color": "paper_dark"},
			{"op": "frame", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper_dark"},
		],
	}
