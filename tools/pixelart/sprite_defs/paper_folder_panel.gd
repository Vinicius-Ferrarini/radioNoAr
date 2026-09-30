extends RefCounted

## Pasta de apuração. A aba cria silhueta própria para briefing e caderno.
static func definition() -> Dictionary:
	return {
		"name": "paper_folder_panel",
		"size": Vector2i(48, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 2, "y": 4, "w": 44, "h": 27, "color": "ink"},
			{"op": "rect", "x": 0, "y": 3, "w": 48, "h": 27, "color": "paper"},
			{"op": "rect", "x": 4, "y": 0, "w": 14, "h": 4, "color": "paper"},
			{"op": "rect", "x": 5, "y": 1, "w": 12, "h": 1, "color": "paper_shade"},
			{"op": "frame", "x": 1, "y": 4, "w": 46, "h": 25, "color": "paper_dark"},
			{"op": "rect", "x": 5, "y": 8, "w": 2, "h": 17, "color": "red_dim"},
			{"op": "rect", "x": 9, "y": 9, "w": 30, "h": 1, "color": "paper_shade"},
			{"op": "rect", "x": 9, "y": 13, "w": 25, "h": 1, "color": "paper_shade"},
		],
	}
