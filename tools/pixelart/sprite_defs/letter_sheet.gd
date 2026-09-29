extends RefCounted

## A folha de carta aberta. Papel creme, com a dobra do meio ainda
## marcada e uma sombra na borda de baixo.

static func definition() -> Dictionary:
	return {
		"name": "letter_sheet",
		"size": Vector2i(32, 32),
		"nine_patch": 10,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper"},
			{"op": "line", "x1": 0, "y1": 15, "x2": 31, "y2": 15, "color": "paper_shade"},
			{"op": "line", "x1": 0, "y1": 16, "x2": 31, "y2": 16, "color": "paper"},
			{"op": "frame", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper_shade"},
			{"op": "line", "x1": 0, "y1": 31, "x2": 31, "y2": 31, "color": "paper_dark"},
			{"op": "line", "x1": 31, "y1": 0, "x2": 31, "y2": 31, "color": "paper_dark"},
		],
	}
