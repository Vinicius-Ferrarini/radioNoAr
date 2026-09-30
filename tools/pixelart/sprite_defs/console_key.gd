extends RefCounted

## Tecla física reutilizável para microfone, corte, música e anúncio.
static func definition() -> Dictionary:
	return {
		"name": "console_key",
		"size": Vector2i(24, 16),
		"nine_patch": 6,
		"primitives": [
			{"op": "rect", "x": 1, "y": 3, "w": 22, "h": 12, "color": "ink"},
			{"op": "rect", "x": 0, "y": 1, "w": 24, "h": 12, "color": "desk_hi"},
			{"op": "frame", "x": 1, "y": 2, "w": 22, "h": 10, "color": "paper_dark"},
			{"op": "rect", "x": 3, "y": 4, "w": 18, "h": 6, "color": "desk_mid"},
			{"op": "rect", "x": 4, "y": 4, "w": 15, "h": 1, "color": "desk_hi"},
		],
	}
