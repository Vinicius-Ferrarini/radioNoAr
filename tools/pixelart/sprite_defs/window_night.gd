extends RefCounted

## Janela panorâmica da cidade. A rua começa vazia; tráfego, pessoas e
## acontecimentos serão camadas da cena, não parte desta base (ADR 0019).
static func definition() -> Dictionary:
	return {"name":"window_night","size":Vector2i(264,102),"primitives":[
		{"op":"rect","x":0,"y":0,"w":264,"h":102,"color":"ink"},
		{"op":"rect","x":2,"y":2,"w":260,"h":98,"color":"desk_hi"},
		{"op":"rect","x":4,"y":4,"w":256,"h":94,"color":"night_deep"},
		{"op":"rect","x":6,"y":6,"w":252,"h":61,"color":"night_blue"},
		{"op":"dither","x":6,"y":6,"w":252,"h":24,"color":"street_blue","step":7},

		{"op":"rect","x":7,"y":38,"w":18,"h":29,"color":"street_blue"},
		{"op":"rect","x":27,"y":30,"w":15,"h":37,"color":"street_blue"},
		{"op":"rect","x":45,"y":43,"w":22,"h":24,"color":"street_blue"},
		{"op":"rect","x":69,"y":25,"w":17,"h":42,"color":"street_blue"},
		{"op":"rect","x":89,"y":37,"w":25,"h":30,"color":"street_blue"},
		{"op":"rect","x":117,"y":29,"w":14,"h":38,"color":"street_blue"},
		{"op":"rect","x":134,"y":42,"w":20,"h":25,"color":"street_blue"},
		{"op":"rect","x":157,"y":24,"w":25,"h":43,"color":"street_blue"},
		{"op":"rect","x":185,"y":35,"w":15,"h":32,"color":"street_blue"},
		{"op":"rect","x":203,"y":28,"w":22,"h":39,"color":"street_blue"},
		{"op":"rect","x":228,"y":40,"w":29,"h":27,"color":"street_blue"},

		{"op":"rect","x":8,"y":53,"w":35,"h":20,"color":"shadow"},
		{"op":"rect","x":47,"y":49,"w":31,"h":24,"color":"desk_dark"},
		{"op":"rect","x":82,"y":55,"w":37,"h":18,"color":"shadow"},
		{"op":"rect","x":123,"y":48,"w":32,"h":25,"color":"desk_dark"},
		{"op":"rect","x":159,"y":54,"w":38,"h":19,"color":"shadow"},
		{"op":"rect","x":201,"y":47,"w":29,"h":26,"color":"desk_dark"},
		{"op":"rect","x":233,"y":55,"w":24,"h":18,"color":"shadow"},

		{"op":"pixels","points":[Vector2i(12,44),Vector2i(19,49),Vector2i(31,37),Vector2i(36,46),Vector2i(51,49),Vector2i(59,55),Vector2i(73,33),Vector2i(80,42),Vector2i(95,45),Vector2i(108,51),Vector2i(121,36),Vector2i(140,49),Vector2i(162,32),Vector2i(174,41),Vector2i(190,44),Vector2i(209,36),Vector2i(219,47),Vector2i(239,48),Vector2i(250,58)],"color":"amber_mid"},
		{"op":"pixels","points":[Vector2i(15,57),Vector2i(26,60),Vector2i(55,58),Vector2i(69,64),Vector2i(91,61),Vector2i(106,58),Vector2i(130,57),Vector2i(146,63),Vector2i(167,61),Vector2i(187,58),Vector2i(207,57),Vector2i(222,63),Vector2i(244,62)],"color":"amber_dim"},
		{"op":"pixels","points":[Vector2i(34,34),Vector2i(76,29),Vector2i(125,32),Vector2i(170,28),Vector2i(214,33)],"color":"cold_glow"},

		{"op":"line","x1":18,"y1":22,"x2":247,"y2":22,"color":"shadow"},
		{"op":"line","x1":7,"y1":28,"x2":222,"y2":28,"color":"shadow"},
		{"op":"line","x1":28,"y1":12,"x2":28,"y2":73,"color":"ink"},
		{"op":"line","x1":219,"y1":18,"x2":219,"y2":73,"color":"ink"},
		{"op":"line","x1":24,"y1":31,"x2":32,"y2":31,"color":"desk_hi"},
		{"op":"line","x1":215,"y1":34,"x2":223,"y2":34,"color":"desk_hi"},
		{"op":"rect","x":24,"y":33,"w":8,"h":3,"color":"amber_hi"},
		{"op":"rect","x":215,"y":36,"w":8,"h":3,"color":"amber_hi"},

		{"op":"rect","x":6,"y":67,"w":252,"h":7,"color":"paper_dark"},
		{"op":"rect","x":6,"y":74,"w":252,"h":24,"color":"night_deep"},
		{"op":"line","x1":6,"y1":76,"x2":257,"y2":76,"color":"desk_mid"},
		{"op":"rect","x":6,"y":96,"w":252,"h":2,"color":"street_blue"},
		{"op":"rect","x":126,"y":78,"w":12,"h":1,"color":"desk_hi"},
		{"op":"rect","x":119,"y":82,"w":26,"h":1,"color":"desk_hi"},
		{"op":"rect","x":108,"y":87,"w":48,"h":1,"color":"desk_hi"},
		{"op":"rect","x":94,"y":93,"w":76,"h":1,"color":"desk_hi"},

		{"op":"line","x1":84,"y1":4,"x2":84,"y2":97,"color":"desk_dark"},
		{"op":"line","x1":176,"y1":4,"x2":176,"y2":97,"color":"desk_dark"},
		{"op":"frame","x":3,"y":3,"w":258,"h":96,"color":"shadow"},
		{"op":"frame","x":0,"y":0,"w":264,"h":102,"color":"desk_hi"},
	]}
