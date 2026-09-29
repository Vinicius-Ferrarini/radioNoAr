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
	# Leitos contínuos: sem envelope nas pontas, para o loop não pulsar.
	_write("room_tone", 4.0, 6, true)
	_write("radio_static", 2.0, 7, true)
	quit()


func _write(id: String, duration: float, kind: int, seamless: bool = false) -> void:
	var data := PackedByteArray()
	var count := int(RATE * duration)
	data.resize(count * 2)
	var melody := [261.63, 329.63, 392.0, 329.63, 293.66, 349.23, 440.0, 349.23]
	# Ruído reproduzível: semente fixa, para o mesmo WAV sair sempre igual.
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260929
	var previous := 0.0
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
			6:
				# Zumbido do estúdio à noite: harmônicas da rede elétrica em
				# ciclos inteiros dentro da duração, para emendar sem estalo.
				wave = (sin(TAU * 50.0 * t) * 0.6 + sin(TAU * 100.0 * t) * 0.25
					+ sin(TAU * 150.0 * t) * 0.1) * 0.09
				wave += sin(TAU * 0.5 * t) * 0.01
			7:
				# Estática: ruído filtrado por média com a amostra anterior.
				var white := rng.randf_range(-1.0, 1.0)
				previous = previous * 0.72 + white * 0.28
				wave = previous * 0.5
		var envelope := 1.0 if seamless 			else minf(1.0, t * 60.0) * minf(1.0, (duration - t) * 30.0)
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
