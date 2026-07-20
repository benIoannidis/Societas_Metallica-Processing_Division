extends Control

signal continue_pressed

@export var terminal_off_sfx: AudioStream
@export var terminal_on_sfx: AudioStream

@onready var title_label_1: Label = $CanvasGroup/Menu/Label
var title_1: String = "Societas\nMetallica"
@onready var title_label_2: Label = $CanvasGroup/Menu/Label2
var title_2: String = "Processing Division"

@onready var terminal: TextureRect = $CanvasGroup/Background

@onready var terminal_hum: AudioStreamPlayer = $TerminalHum

@onready var play_continue_button: TextureButton = $CanvasGroup/Menu/PlayButton
@onready var stats_button: TextureButton = $CanvasGroup/Menu/StatsButton
@onready var exit_button: TextureButton = $CanvasGroup/Menu/ExitButton

@onready var menu_screen: Control = $CanvasGroup/Menu
@onready var static_overlay: ColorRect = $StaticOverlay
@onready var stats_screen: Control = $CanvasGroup/Stats


var last_char_count: int = 0

func _ready() -> void:
	hide_screen()
	GameManager.menu_open.connect(on_ready)

func on_ready() -> void:
	self.visible = true
	
	boot_up_terminal()

func hide_screen() -> void:
	terminal.scale = Vector2.ZERO
	play_continue_button.modulate = Color(0.0,0.0,0.0,0.0)
	stats_button.modulate = Color(0.0,0.0,0.0,0.0)
	exit_button.modulate = Color(0.0,0.0,0.0,0.0)
	
	play_continue_button.disabled = true
	stats_button.disabled = true
	exit_button.disabled = true
	
	title_label_1.text = ""
	title_label_2.text = ""
	title_label_1.modulate = Color.from_hsv(0.07, 0.51, 1.0, 1.0)
	title_label_2.modulate = Color.from_hsv(0.06, 0.67, 1.0, 1.0)
	
	static_overlay.visible = false

func boot_up_terminal() -> void:
	# boot up stuff
	terminal.modulate = Color(4.0, 4.0, 4.0, 1.0)
	
	var boot_tween: Tween = create_tween()
	terminal.scale = Vector2(0.01, 0.01)
	boot_tween.parallel().tween_property(terminal, "scale:x", 1.0, 0.3)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	var audio_player: AudioStreamPlayer = get_audio_child(terminal)
	audio_player.stream = terminal_on_sfx
	audio_player.play()
	
	boot_tween.tween_property(terminal, "scale:y", 1.0, 0.25)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	boot_tween.parallel().tween_property(terminal, "modulate", Color(0.3,0.3,0.3,1.0), 0.8)
	
	await boot_tween.finished
	terminal_hum.start_hum()
	fade_in_logo()

func shut_down_terminal() -> void:
	terminal.modulate = Color(0.9, 0.9, 0.9, 1.0)
	
	var shutdown_tween: Tween = create_tween()
	shutdown_tween.parallel().tween_property(title_label_1, "modulate", Color(0.9, 0.9, 0.9, 1.0), 0.2)
	shutdown_tween.parallel().tween_property(title_label_2, "modulate", Color(0.9, 0.9, 0.9, 1.0), 0.2)
	
	shutdown_tween.parallel().tween_property(play_continue_button, "modulate", Color(0.0, 0.0, 0.0, 1.0), 0.2)
	shutdown_tween.parallel().tween_property(stats_button, "modulate", Color(0.0, 0.0, 0.0, 1.0), 0.2)
	shutdown_tween.parallel().tween_property(exit_button, "modulate", Color(0.0, 0.0, 0.0, 1.0), 0.2)
	
	shutdown_tween.tween_property(title_label_1, "modulate", Color.TRANSPARENT, 0.2)
	shutdown_tween.tween_property(title_label_2, "modulate", Color.TRANSPARENT, 0.2)
	shutdown_tween.tween_property(play_continue_button, "modulate", Color.TRANSPARENT, 0.2)
	shutdown_tween.tween_property(stats_button, "modulate", Color.TRANSPARENT, 0.2)
	shutdown_tween.tween_property(exit_button, "modulate", Color.TRANSPARENT, 0.2)
	
	shutdown_tween.tween_interval(0.2)
	
	shutdown_tween.parallel().tween_property(terminal, "scale:y", 0.01, 0.2)\
	.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	
	var audio_player: AudioStreamPlayer = get_audio_child(terminal)
	audio_player.stream = terminal_off_sfx
	shutdown_tween.tween_callback(func(): audio_player.play())
	
	shutdown_tween.tween_property(terminal, "scale:x", 0.01, 0.2)\
	.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	
	
	
	shutdown_tween.parallel().tween_property(terminal, "modulate", Color(0,0,0,0.5), 0.4)
	
	await shutdown_tween.finished
	GameManager.cut_audio.emit()

func get_audio_child(terminal: TextureRect) -> AudioStreamPlayer:
	for child in terminal.get_children():
		if child is AudioStreamPlayer:
			return child 
	return null

func animate_title() -> void:
	var speed: float = 0.05
	
	var first_duration: float = title_1.length() * speed
	var second_duration: float = title_2.length() * speed
	
	var animation_tween: Tween = create_tween()
	
	last_char_count = 0
	
	animation_tween.tween_method(
		func(char_count: int):
			if char_count > last_char_count:
				var current_char = title_1.substr(char_count - 1, 1)
				play_procedural_clack(Vector2(150.0, 200.0))
				last_char_count = char_count
			title_label_1.text = title_1.left(char_count), 
			0,
			title_1.length(),
			first_duration
	).set_trans(Tween.TRANS_LINEAR)
	
	animation_tween.tween_interval(0.3)
	
	animation_tween.tween_callback(func(): last_char_count = 0)
	animation_tween.tween_method(
		func(char_count: int):
			if char_count > last_char_count:
				var current_char = title_2.substr(char_count - 1, 1)
				play_procedural_clack(Vector2(80.0, 120.0))
				last_char_count = char_count
			title_label_2.text = title_2.left(char_count),
			0,
			title_2.length(),
			second_duration
	).set_trans(Tween.TRANS_LINEAR)
	
	await animation_tween.finished
	await get_tree().create_timer(0.5).timeout
	fade_in_buttons()

func play_procedural_clack(frequency_range: Vector2) -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.1
	
	var clack_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(clack_player)
	clack_player.stream = generator
	clack_player.play()
	
	var playback: AudioStreamPlayback = clack_player.get_stream_playback()
	if not playback:
		clack_player.queue_free()
		return
	
	var sample_rate: float = generator.mix_rate
	var click_duration: float = 0.05
	var num_frames: int = int(sample_rate * click_duration)
	
	var base_frequency: float = randf_range(frequency_range.x, frequency_range.y)
	var dynamic_volume: float = randf_range(0.03, 0.045)
	var noise_blend: float = randf_range(0.15, 0.35)
	
	var phase: float = 0.0
	
	for i in range(num_frames):
		var progress: float = float(i) / num_frames
		
		var increment: float = base_frequency / sample_rate
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var square_component: float = 1.0 if phase < 0.5 else -1.0
		var noise_component: float = randf_range(-1.0, 1.0)
		
		var raw_sample: float = (square_component * (1.0 - noise_blend)) + (noise_component * noise_blend)
		
		var envelope: float = exp(-progress * 12.0)
		var final_sample: float = raw_sample * dynamic_volume * envelope
		
		playback.push_frame(Vector2(final_sample, final_sample))
	
	get_tree().create_timer(0.15).timeout.connect(func(): clack_player.queue_free())

func fade_in_logo() -> void:
	var fade_in_tween: Tween = create_tween()
	
	var target_colour: Color = Color.from_hsv(1.0, 0.67, 1.0, 1.0)
	
	fade_in_tween.tween_property(terminal, "modulate", target_colour, 0.75)
	
	await fade_in_tween.finished
	animate_title()

func fade_in_buttons() -> void:
	var target_colour_1: Color = Color(0.1, 0.1, 0.1, 1.0)
	var target_colour_2: Color = Color(0.9,0.9,0.9, 1.0)
	
	var fade_in_tween: Tween = create_tween()
	
	fade_in_tween.tween_callback(play_button_blip)
	
	fade_in_tween.tween_property(play_continue_button, "modulate", target_colour_1, 0.3)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	fade_in_tween.tween_interval(0.1)
	
	fade_in_tween.tween_callback(play_button_blip)
	fade_in_tween.parallel().tween_property(stats_button, "modulate", target_colour_1, 0.3)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	fade_in_tween.tween_interval(0.1)
	
	fade_in_tween.tween_callback(play_button_blip)
	fade_in_tween.parallel().tween_property(exit_button, "modulate", target_colour_1, 0.3)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	fade_in_tween.tween_callback(func(): play_button_fade_noise(0.1))
	
	fade_in_tween.tween_interval(0.05)
	fade_in_tween.tween_property(play_continue_button, "modulate", target_colour_2, 0.1)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	fade_in_tween.tween_callback(func(): play_button_fade_noise(0.1))
	fade_in_tween.tween_interval(0.05)
	
	fade_in_tween.parallel().tween_property(stats_button, "modulate", target_colour_2, 0.1)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	fade_in_tween.tween_callback(func(): play_button_fade_noise(0.1))
	fade_in_tween.tween_interval(0.05)
	fade_in_tween.parallel().tween_property(exit_button, "modulate", target_colour_2, 0.1)\
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	await fade_in_tween.finished
	play_continue_button.disabled = false
	stats_button.disabled = false
	exit_button.disabled = false

func play_button_blip(frequency: float = randf_range(150.0, 200.0)) -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.15
	
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.stream = generator
	player.play()
	
	var playback: AudioStreamPlayback = player.get_stream_playback()
	if not playback:
		return
	
	var duration: float = 0.06
	var num_frames: int = int(generator.mix_rate * duration)
	var phase: float = 0.0
	
	for i in range(num_frames):
		var progress: float = float(i) / num_frames
		var increment: float = frequency / 44100.0
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var sample: float = 0.03 if phase < 0.5 else -0.03
		sample *= 1.0 - progress
		playback.push_frame(Vector2(sample, sample))
	
	get_tree().create_timer(0.2).timeout.connect(func(): player.queue_free())

func play_button_fade_noise(duration: float) -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = duration + 0.1
	
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.stream = generator
	player.play()
	
	var playback: AudioStreamPlayback = player.get_stream_playback()
	if not playback:
		return
	
	var num_frames: int = int(generator.mix_rate * duration)
	
	var current_noise_value: float = 0.0
	var downsample_rate: int = 8
	
	for i in range(num_frames):
		var progress: float = float(i) / num_frames
		
		if i % downsample_rate == 0:
			current_noise_value = randf_range(-1.0, 1.0)
		
		var raw_sine: float = sin(progress * PI)
		
		var volume_envelope: float = (raw_sine * raw_sine) * 0.05
		var sample: float = current_noise_value * volume_envelope
		
		playback.push_frame(Vector2(sample, sample))
	
	get_tree().create_timer(duration + 0.15).timeout.connect(func(): player.queue_free())

func _on_play_continue_button_button_down() -> void:
	play_button_blip(100.0)
	await get_tree().create_timer(0.1).timeout
	play_button_blip(120.0)

func _on_play_continue_button_button_up() -> void:
	await shut_down_terminal()
	continue_pressed.emit()

func _on_stats_button_button_down() -> void:
	play_button_blip(120.0)
	await get_tree().create_timer(0.4).timeout
	play_button_blip(180.0)

func _on_stats_button_button_up() -> void:
	show_stats()

func _on_exit_button_button_down() -> void:
	play_button_blip(130.0)
	await get_tree().create_timer(0.1).timeout
	play_button_blip(100.0)


func _on_exit_button_button_up() -> void:
	await shut_down_terminal()
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func show_stats() -> void:
	static_overlay.visible = true
	menu_screen.visible = false
	stats_screen.visible = true
	await get_tree().create_timer(0.75).timeout
	static_overlay.visible = false

func hide_stats() -> void:
	pass
