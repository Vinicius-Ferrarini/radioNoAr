extends RefCounted

## O X que fecha o close e devolve a mesa.

static func definition() -> Dictionary:
	return {
		"name": "close_button",
		"size": Vector2i(12, 12),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 12, "h": 12, "color": "desk_dark"},
			{"op": "frame", "x": 0, "y": 0, "w": 12, "h": 12, "color": "desk_hi"},
			{"op": "pixels", "points": [
				Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 5), Vector2i(6, 6), Vector2i(7, 7), Vector2i(8, 8),
				Vector2i(8, 3), Vector2i(7, 4), Vector2i(6, 5), Vector2i(5, 6), Vector2i(4, 7), Vector2i(3, 8)
			], "color": "paper_shade"},
		],
	}
