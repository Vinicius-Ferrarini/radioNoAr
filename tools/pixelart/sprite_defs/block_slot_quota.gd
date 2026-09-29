extends RefCounted

## O bloco de cota: moldura tracejada, porque aquele espaço não é seu.

static func definition() -> Dictionary:
	return {
		"name": "block_slot_quota",
		"size": Vector2i(16, 16),
		"nine_patch": 5,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "desk_dark"},
			{"op": "dither", "x": 0, "y": 0, "w": 16, "h": 1, "color": "red_hi", "step": 2},
			{"op": "dither", "x": 0, "y": 15, "w": 16, "h": 1, "color": "red_hi", "step": 2},
			{"op": "dither", "x": 0, "y": 0, "w": 1, "h": 16, "color": "red_hi", "step": 2},
			{"op": "dither", "x": 15, "y": 0, "w": 1, "h": 16, "color": "red_hi", "step": 2},
		],
	}
