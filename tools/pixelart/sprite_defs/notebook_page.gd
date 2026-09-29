extends RefCounted

## A página do caderno aberta: pauta, margem vermelha e a espiral na
## esquerda. O que estica é a pauta.

static func definition() -> Dictionary:
	return {
		"name": "notebook_page",
		"size": Vector2i(32, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper"},
			{"op": "rect", "x": 0, "y": 0, "w": 6, "h": 32, "color": "paper_shade"},
			{"op": "line", "x1": 7, "y1": 0, "x2": 7, "y2": 31, "color": "red_dim"},
			{"op": "pixels", "points": [
				Vector2i(2, 3), Vector2i(3, 3), Vector2i(2, 4), Vector2i(3, 4),
				Vector2i(2, 15), Vector2i(3, 15), Vector2i(2, 16), Vector2i(3, 16),
				Vector2i(2, 27), Vector2i(3, 27), Vector2i(2, 28), Vector2i(3, 28)
			], "color": "desk_hi"},
			{"op": "frame", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper_dark"},
		],
	}
