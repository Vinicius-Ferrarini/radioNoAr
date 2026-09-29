extends RefCounted

## Ministério das Comunicações. Não é foto: é o brasão, a torre de
## transmissão do selo oficial, impressa em cima do comunicado.

static func definition() -> Dictionary:
	return {
		"name": "avatar_ministerio",
		"size": Vector2i(16, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "paper_shade"},
			{"op": "frame", "x": 1, "y": 1, "w": 14, "h": 14, "color": "red_dim"},
			{"op": "rect", "x": 7, "y": 3, "w": 2, "h": 9, "color": "red_dim"},
			{"op": "pixels", "points": [
				Vector2i(6, 5), Vector2i(9, 5), Vector2i(5, 7), Vector2i(10, 7),
				Vector2i(4, 9), Vector2i(11, 9), Vector2i(4, 11), Vector2i(11, 11)
			], "color": "red_dim"},
			{"op": "rect", "x": 5, "y": 12, "w": 6, "h": 1, "color": "red_dim"},
			{"op": "pixels", "points": [Vector2i(7, 2), Vector2i(8, 2)], "color": "red_hi"},
		],
	}
