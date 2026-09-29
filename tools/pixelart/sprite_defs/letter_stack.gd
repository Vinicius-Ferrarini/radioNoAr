extends RefCounted

## A pilha de cartas. O lacre é o que se confere: envelope reselado
## significa que o governo leu antes de você.

static func definition() -> Dictionary:
	return {
		"name": "letter_stack",
		"size": Vector2i(44, 26),
		"primitives": [
			{"op": "rect", "x": 4, "y": 12, "w": 40, "h": 13, "color": "paper_shade"},
			{"op": "frame", "x": 4, "y": 12, "w": 40, "h": 13, "color": "paper_dark"},
			{"op": "rect", "x": 0, "y": 6, "w": 40, "h": 15, "color": "paper"},
			{"op": "line", "x1": 1, "y1": 13, "x2": 38, "y2": 13, "color": "paper_shade"},
			{"op": "dither", "x": 4, "y": 16, "w": 20, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "dither", "x": 4, "y": 18, "w": 14, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "rect", "x": 29, "y": 8, "w": 7, "h": 5, "color": "red_dim"},
			{"op": "frame", "x": 29, "y": 8, "w": 7, "h": 5, "color": "paper_dark"},
			{"op": "frame", "x": 0, "y": 6, "w": 40, "h": 15, "color": "paper_dark"},
		],
	}
