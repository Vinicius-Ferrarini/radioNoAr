extends RefCounted

## O lacre da carta. Inteiro significa que ninguém abriu — ou que quem
## abriu tinha lacre igual.
##
## 20x20 igual ao carimbo de propósito: os dois dividem o mesmo lugar no
## close, e um slot que troca de textura não pode mudar de tamanho.

static func definition() -> Dictionary:
	return {
		"name": "wax_seal",
		"size": Vector2i(20, 20),
		"primitives": [
			{"op": "rect", "x": 6, "y": 3, "w": 8, "h": 14, "color": "red_dim"},
			{"op": "rect", "x": 3, "y": 6, "w": 14, "h": 8, "color": "red_dim"},
			{"op": "rect", "x": 5, "y": 5, "w": 10, "h": 10, "color": "red_dim"},
			{"op": "rect", "x": 7, "y": 7, "w": 6, "h": 6, "color": "red_hi"},
			{"op": "pixels", "points": [
				Vector2i(8, 8), Vector2i(9, 9), Vector2i(10, 10), Vector2i(11, 9), Vector2i(9, 11)
			], "color": "paper_shade"},
			{"op": "pixels", "points": [
				Vector2i(4, 4), Vector2i(15, 4), Vector2i(4, 15), Vector2i(15, 15),
				Vector2i(3, 5), Vector2i(16, 5), Vector2i(5, 16), Vector2i(14, 16)
			], "color": "shadow"},
		],
	}
