extends RefCounted

## A madeira da mesa. Nine-patch: estica sem repetir padrão visível.

static func definition() -> Dictionary:
	return {
		"name": "desk_surface",
		"size": Vector2i(24, 24),
		"nine_patch": 6,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 24, "h": 24, "color": "desk_mid"},
			{"op": "dither", "x": 0, "y": 0, "w": 24, "h": 24, "color": "desk_dark", "step": 3},
			{"op": "line", "x1": 0, "y1": 0, "x2": 23, "y2": 0, "color": "desk_hi"},
			{"op": "line", "x1": 0, "y1": 23, "x2": 23, "y2": 23, "color": "shadow"},
		],
	}
