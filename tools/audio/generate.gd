extends SceneTree

## Sons originais sintetizados, determinísticos, sem arquivos externos.
## Execute: Godot --headless -s tools/audio/generate.gd
const RATE := 22050


func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/audio")
	_write("switch", 0.08, 0)
	_write("phone_ring", 1.2, 1)
	_write("station_jingle", 2.0, 2)
	_write("neighborhood_waltz", 6.0, 3)
	_write("workshop_ad", 6.0, 4)
	_write("line_cut", 0.3, 5)
	quit()


func _write(id: String, duration: float, kind: int) -> void:
	var data := PackedByteArray()
	var count := int(RATE * duration)
	data.resize(count * 2)
	var melody := [261.63, 329.63, 392.0, 329.63, 293.66, 349.23, 440.0, 349.23]
	for i in count:
		var t := float(i) / RATE
		var wave := 0.0
		match kind:
			0: wave = sin(t * 1700.0) * exp(-t * 75.0)
			1: wave = (sin(TAU * 440 * t) + sin(TAU * 480 * t)) * 0.25 if fmod(t, 0.5) < 0.3 else 0.0
			2: wave = sin(TAU * float(melody[mini(int(t * 4), 7)]) * t) * 0.35
			3:
				var frequency: float = melody[int(t * 2) % melody.size()]
				wave = (sin(TAU * frequency * t) + 0.25 * sin(TAU * frequency * 2 * t)) * 0.22 * (1.0 - fmod(t, 0.5))
			4: wave = sin(TAU * float([392, 523, 659, 523][int(t * 3) % 4]) * t) * 0.22
			5: wave = sin(TAU * 160 * t) * exp(-t * 12.0) * 0.4
		var envelope := minf(1.0, t * 60.0) * minf(1.0, (duration - t) * 30.0)
		data.encode_s16(i * 2, int(clampf(wave * envelope, -1, 1) * 18000))
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = RATE
	audio.data = data
	var error := audio.save_to_wav("res://assets/audio/" + id + ".wav")
	if error != OK:
		push_error("Falha ao salvar áudio: " + id)
		quit(1)
	print("[audio] ", id)
