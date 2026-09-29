extends RefCounted

## O caderno do apresentador: o livro de regras que cresce a cada noite.

static func definition() -> Dictionary:
	return {
		"name": "notebook",
		"size": Vector2i(34, 26),
		"primitives": [
			{"op": "rect", "x": 2, "y": 0, "w": 32, "h": 26, "color": "paper"},
			{"op": "rect", "x": 2, "y": 0, "w": 5, "h": 26, "color": "red_dim"},
			{"op": "pixels", "points": [Vector2i(0, 3), Vector2i(0, 8), Vector2i(0, 13), Vector2i(0, 18), Vector2i(0, 23), Vector2i(1, 3), Vector2i(1, 8), Vector2i(1, 13), Vector2i(1, 18), Vector2i(1, 23)], "color": "desk_hi"},
			{"op": "dither", "x": 10, "y": 5, "w": 21, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "dither", "x": 10, "y": 9, "w": 21, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "dither", "x": 10, "y": 13, "w": 16, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "dither", "x": 10, "y": 17, "w": 21, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "dither", "x": 10, "y": 21, "w": 12, "h": 1, "color": "paper_dark", "step": 2},
			{"op": "frame", "x": 2, "y": 0, "w": 32, "h": 26, "color": "paper_dark"},
		],
	}
