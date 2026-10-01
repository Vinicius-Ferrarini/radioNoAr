extends RefCounted

## Rui: motorista em três quartos, boné e uniforme dentro da cabine;
## volante e janela fazem parte da silhueta do contato.
static func definition() -> Dictionary:
	return {"name":"avatar_rui","size":Vector2i(32,32),"primitives":[
		{"op":"rect","x":0,"y":0,"w":32,"h":32,"color":"night_deep"},
		{"op":"rect","x":1,"y":1,"w":30,"h":30,"color":"night_blue"},
		{"op":"line","x1":24,"y1":1,"x2":24,"y2":25,"color":"street_hi"},
		{"op":"line","x1":29,"y1":2,"x2":29,"y2":24,"color":"desk_hi"},
		{"op":"pixels","points":[Vector2i(27,5),Vector2i(27,12),Vector2i(27,19),Vector2i(3,7)],"color":"amber_mid"},
		{"op":"rect","x":8,"y":7,"w":17,"h":16,"color":"amber_dim"},
		{"op":"rect","x":10,"y":9,"w":13,"h":13,"color":"amber_mid"},
		{"op":"pixels","points":[Vector2i(7,11),Vector2i(7,12),Vector2i(24,10),Vector2i(25,11),Vector2i(24,18),Vector2i(23,21),Vector2i(11,22)],"color":"amber_dim"},
		{"op":"rect","x":7,"y":4,"w":18,"h":5,"color":"street_blue"},
		{"op":"rect","x":11,"y":2,"w":12,"h":4,"color":"street_hi"},
		{"op":"line","x1":22,"y1":8,"x2":27,"y2":8,"color":"street_blue"},
		{"op":"pixels","points":[Vector2i(13,12),Vector2i(20,12)],"color":"ink"},
		{"op":"line","x1":16,"y1":13,"x2":16,"y2":16,"color":"amber_dim"},
		{"op":"pixels","points":[Vector2i(15,17),Vector2i(16,18),Vector2i(17,17)],"color":"desk_dark"},
		{"op":"line","x1":13,"y1":20,"x2":20,"y2":20,"color":"ink"},
		{"op":"pixels","points":[Vector2i(11,18),Vector2i(12,20),Vector2i(13,22),Vector2i(14,23),Vector2i(19,23),Vector2i(21,22),Vector2i(22,20)],"color":"shadow"},
		{"op":"rect","x":5,"y":25,"w":22,"h":7,"color":"street_blue"},
		{"op":"line","x1":15,"y1":25,"x2":15,"y2":31,"color":"paper_shade"},
		{"op":"rect","x":20,"y":27,"w":4,"h":3,"color":"paper"},
		{"op":"pixels","points":[Vector2i(2,31),Vector2i(3,28),Vector2i(5,26),Vector2i(8,24),Vector2i(11,23),Vector2i(14,22),Vector2i(18,22),Vector2i(22,23),Vector2i(25,25),Vector2i(28,28),Vector2i(29,31)],"color":"desk_dark"},
		{"op":"pixels","points":[Vector2i(4,31),Vector2i(5,28),Vector2i(8,26),Vector2i(12,24),Vector2i(20,24),Vector2i(24,26),Vector2i(27,29),Vector2i(28,31)],"color":"paper_dark"},
	],"source_details":[
		{"op":"line","x1":23,"y1":9,"x2":42,"y2":9,"color":"cold_glow"},
		{"op":"pixels","points":[Vector2i(26,25),Vector2i(39,25),Vector2i(31,37),Vector2i(35,39),Vector2i(39,37)],"color":"desk_dark"},
		{"op":"line","x1":42,"y1":56,"x2":47,"y2":56,"color":"paper_shade"},
		{"op":"pixels","points":[Vector2i(54,9),Vector2i(56,21),Vector2i(54,36)],"color":"amber_hi"}
	]}
