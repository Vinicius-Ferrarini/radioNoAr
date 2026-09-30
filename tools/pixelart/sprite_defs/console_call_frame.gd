extends RefCounted

## Moldura metálica do canal telefônico ao vivo. O centro recebe texto e
## controles Godot; as bordas dão identidade de equipamento de rádio.
static func definition() -> Dictionary:
	return {
		"name": "console_call_frame",
		"size": Vector2i(48, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 48, "h": 32, "color": "ink"},
			{"op": "frame", "x": 1, "y": 1, "w": 46, "h": 30, "color": "desk_hi"},
			{"op": "frame", "x": 3, "y": 3, "w": 42, "h": 26, "color": "desk_mid"},
			{"op": "rect", "x": 6, "y": 6, "w": 36, "h": 20, "color": "shadow"},
			{"op": "frame", "x": 6, "y": 6, "w": 36, "h": 20, "color": "desk_dark"},
			{"op": "rect", "x": 2, "y": 14, "w": 2, "h": 4, "color": "amber_dim"},
			{"op": "rect", "x": 44, "y": 14, "w": 2, "h": 4, "color": "amber_dim"},
			{"op": "pixels", "points": [Vector2i(3, 3), Vector2i(44, 3), Vector2i(3, 28), Vector2i(44, 28)], "color": "paper_dark"},
		],
	}
