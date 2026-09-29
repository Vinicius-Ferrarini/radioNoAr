extends RefCounted

## Um dos 4 blocos do programa, vazio. Nine-patch.

static func definition() -> Dictionary:
	return {
		"name": "block_slot",
		"size": Vector2i(16, 16),
		"nine_patch": 5,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "desk_dark"},
			{"op": "frame", "x": 1, "y": 1, "w": 14, "h": 14, "color": "shadow"},
			{"op": "frame", "x": 0, "y": 0, "w": 16, "h": 16, "color": "desk_hi"},
		],
	}
