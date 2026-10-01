extends RefCounted

## Dona Célia: retrato doméstico, coque grisalho, óculos dourados e
## cardigan. O fundo guarda o rádio e a parede quente da referência.
static func definition() -> Dictionary:
	return {"name":"avatar_celia","size":Vector2i(32,32),"primitives":[
		{"op":"rect","x":0,"y":0,"w":32,"h":32,"color":"night_blue"},
		{"op":"rect","x":1,"y":1,"w":30,"h":30,"color":"desk_dark"},
		{"op":"rect","x":2,"y":3,"w":7,"h":15,"color":"desk_mid"},
		{"op":"dither","x":2,"y":3,"w":7,"h":15,"color":"amber_dim","step":3},
		{"op":"rect","x":25,"y":4,"w":5,"h":9,"color":"shadow"},
		{"op":"frame","x":26,"y":5,"w":3,"h":5,"color":"amber_dim"},
		{"op":"rect","x":13,"y":1,"w":8,"h":5,"color":"paper_dark"},
		{"op":"rect","x":11,"y":3,"w":12,"h":6,"color":"paper_shade"},
		{"op":"pixels","points":[Vector2i(12,2),Vector2i(14,0),Vector2i(15,0),Vector2i(16,0),Vector2i(17,0),Vector2i(18,0),Vector2i(20,2),Vector2i(10,5),Vector2i(22,5)],"color":"paper_dark"},
		{"op":"rect","x":8,"y":8,"w":17,"h":14,"color":"amber_dim"},
		{"op":"rect","x":10,"y":8,"w":13,"h":14,"color":"amber_mid"},
		{"op":"pixels","points":[Vector2i(9,7),Vector2i(10,6),Vector2i(11,6),Vector2i(21,6),Vector2i(22,7),Vector2i(23,8),Vector2i(24,9),Vector2i(8,11),Vector2i(8,12),Vector2i(24,12)],"color":"paper_shade"},
		{"op":"rect","x":8,"y":13,"w":2,"h":5,"color":"amber_mid"},
		{"op":"rect","x":23,"y":13,"w":2,"h":5,"color":"amber_mid"},
		{"op":"frame","x":10,"y":12,"w":6,"h":5,"color":"glow"},
		{"op":"frame","x":18,"y":12,"w":6,"h":5,"color":"glow"},
		{"op":"line","x1":15,"y1":14,"x2":18,"y2":14,"color":"glow"},
		{"op":"pixels","points":[Vector2i(12,14),Vector2i(21,14)],"color":"ink"},
		{"op":"line","x1":16,"y1":15,"x2":16,"y2":18,"color":"amber_dim"},
		{"op":"pixels","points":[Vector2i(15,18),Vector2i(16,19),Vector2i(17,18)],"color":"desk_dark"},
		{"op":"line","x1":13,"y1":20,"x2":19,"y2":20,"color":"red_dim"},
		{"op":"pixels","points":[Vector2i(14,21),Vector2i(15,22),Vector2i(16,22),Vector2i(17,22),Vector2i(18,21),Vector2i(7,17),Vector2i(25,17)],"color":"glow"},
		{"op":"rect","x":4,"y":24,"w":24,"h":8,"color":"red_dim"},
		{"op":"rect","x":7,"y":23,"w":19,"h":3,"color":"red_hi"},
		{"op":"rect","x":11,"y":24,"w":11,"h":8,"color":"paper"},
		{"op":"pixels","points":[Vector2i(12,25),Vector2i(15,25),Vector2i(19,25),Vector2i(13,27),Vector2i(17,27),Vector2i(20,28),Vector2i(14,30),Vector2i(18,31)],"color":"amber_mid"},
	],"source_details":[
		{"op":"pixels","points":[Vector2i(23,27),Vector2i(25,27),Vector2i(39,27),Vector2i(41,27)],"color":"paper"},
		{"op":"line","x1":27,"y1":37,"x2":31,"y2":37,"color":"amber_dim"},
		{"op":"line","x1":34,"y1":37,"x2":38,"y2":37,"color":"amber_dim"},
		{"op":"pixels","points":[Vector2i(25,47),Vector2i(31,49),Vector2i(37,48),Vector2i(42,51),Vector2i(28,57),Vector2i(35,59)],"color":"glow"}
	]}
