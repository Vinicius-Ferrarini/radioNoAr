extends RefCounted

## A moldura do teleprompter. Nine-patch: o texto dentro é fonte
## nítida, não pixel art (ADR 0006).

static func definition() -> Dictionary:
	return {
		"name": "teleprompter_frame",
		"size": Vector2i(24, 24),
		"nine_patch": 8,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 24, "h": 24, "color": "desk_dark"},
			{"op": "frame", "x": 0, "y": 0, "w": 24, "h": 24, "color": "desk_hi"},
			{"op": "rect", "x": 3, "y": 3, "w": 18, "h": 18, "color": "ink"},
			{"op": "frame", "x": 3, "y": 3, "w": 18, "h": 18, "color": "shadow"},
			{"op": "pixels", "points": [Vector2i(2, 2), Vector2i(21, 2), Vector2i(2, 21), Vector2i(21, 21)], "color": "amber_dim"},
		],
	}
