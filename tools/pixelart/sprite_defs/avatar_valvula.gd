extends RefCounted

## Oficina do Portão Doze: fachada noturna, portão numerado, luz de
## serviço, ferramenta e caixa vermelha. A ausência de rosto é intencional.
static func definition() -> Dictionary:
	return {"name":"avatar_valvula","size":Vector2i(32,32),"primitives":[
		{"op":"rect","x":0,"y":0,"w":32,"h":32,"color":"night_deep"},
		{"op":"rect","x":1,"y":1,"w":30,"h":30,"color":"desk_dark"},
		{"op":"rect","x":2,"y":2,"w":28,"h":5,"color":"night_blue"},
		{"op":"pixels","points":[Vector2i(3,5),Vector2i(5,3),Vector2i(7,4),Vector2i(25,3),Vector2i(27,5)],"color":"street_hi"},
		{"op":"rect","x":3,"y":6,"w":26,"h":23,"color":"desk_mid"},
		{"op":"frame","x":5,"y":8,"w":21,"h":19,"color":"desk_hi"},
		{"op":"rect","x":6,"y":9,"w":19,"h":17,"color":"street_blue"},
		{"op":"line","x1":6,"y1":13,"x2":24,"y2":13,"color":"night_blue"},
		{"op":"line","x1":6,"y1":17,"x2":24,"y2":17,"color":"night_blue"},
		{"op":"line","x1":6,"y1":21,"x2":24,"y2":21,"color":"night_blue"},
		{"op":"rect","x":4,"y":3,"w":7,"h":4,"color":"amber_dim"},
		{"op":"rect","x":5,"y":4,"w":5,"h":2,"color":"amber_hi"},
		{"op":"pixels","points":[Vector2i(3,7),Vector2i(4,8),Vector2i(5,9),Vector2i(6,10)],"color":"amber_mid"},
		{"op":"line","x1":11,"y1":10,"x2":11,"y2":15,"color":"paper"},
		{"op":"line","x1":10,"y1":10,"x2":13,"y2":10,"color":"paper"},
		{"op":"line","x1":16,"y1":10,"x2":20,"y2":10,"color":"paper"},
		{"op":"line","x1":20,"y1":10,"x2":20,"y2":12,"color":"paper"},
		{"op":"line","x1":16,"y1":12,"x2":20,"y2":12,"color":"paper"},
		{"op":"line","x1":16,"y1":12,"x2":16,"y2":15,"color":"paper"},
		{"op":"line","x1":16,"y1":15,"x2":20,"y2":15,"color":"paper"},
		{"op":"pixels","points":[Vector2i(8,24),Vector2i(9,23),Vector2i(10,22),Vector2i(11,21),Vector2i(12,20),Vector2i(13,19),Vector2i(14,18),Vector2i(15,17),Vector2i(16,18),Vector2i(17,18),Vector2i(18,17),Vector2i(17,16),Vector2i(16,16),Vector2i(15,17),Vector2i(7,24),Vector2i(8,25)],"color":"paper_shade"},
		{"op":"rect","x":22,"y":22,"w":7,"h":7,"color":"red_dim"},
		{"op":"line","x1":22,"y1":23,"x2":28,"y2":23,"color":"red_hi"},
		{"op":"rect","x":24,"y":20,"w":3,"h":2,"color":"desk_hi"},
		{"op":"rect","x":0,"y":29,"w":32,"h":3,"color":"amber_dim"},
		{"op":"dither","x":0,"y":29,"w":32,"h":3,"color":"shadow","step":2},
	],"source_details":[
		{"op":"pixels","points":[Vector2i(11,18),Vector2i(49,18),Vector2i(11,34),Vector2i(49,34),Vector2i(11,50),Vector2i(49,50)],"color":"desk_hi"},
		{"op":"line","x1":15,"y1":29,"x2":45,"y2":29,"color":"street_hi"},
		{"op":"line","x1":15,"y1":45,"x2":45,"y2":45,"color":"street_hi"},
		{"op":"pixels","points":[Vector2i(9,11),Vector2i(12,13),Vector2i(15,15),Vector2i(50,47),Vector2i(54,51)],"color":"amber_hi"}
	]}
