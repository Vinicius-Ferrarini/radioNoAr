class_name EndingResolver
extends RefCounted


static func resolve(power: int) -> String:
	if power > 65:
		return "repressao"
	if power < 35:
		return "reforma"
	return "cinza"
