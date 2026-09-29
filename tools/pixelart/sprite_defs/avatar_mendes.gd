extends RefCounted

## A irmã de A. Mendes. A foto é dos dois; ela cortou a parte dela para
## caber, então quem aparece é o irmão, meio de lado, meio apagado.

static func definition() -> Dictionary:
	return {
		"name": "avatar_mendes",
		"size": Vector2i(16, 16),
		"legend": {
			".": "paper_dark",
			"p": "paper_shade",
			"s": "shadow",
			"d": "desk_dark",
			"a": "amber_dim",
		},
		"rows": PackedStringArray([
			"pppppppppppppppp",
			"pp...........ppp",
			"pp...sssss...ppp",
			"pp..sdaaads..ppp",
			"pp..sdaaads..ppp",
			"pp..ssaaass..ppp",
			"pp...daaad...ppp",
			"pp...ddadd...ppp",
			"pp....ddd....ppp",
			"pp...sssss...ppp",
			"pp..sssssss..ppp",
			"pp.sssssssss.ppp",
			"pp.sssssssss.ppp",
			"pp.sssssssss.ppp",
			"pppppppppppppppp",
			"pppppppppppppppp",
		]),
	}
