extends AudioStreamPlayer

@onready var terminal: Control = $".."

func _ready() -> void:
	terminal.boot_finished.connect(start_up_sound)
	terminal.terminal_beep_sfx.connect(func():play_blip_sfx(false))
	terminal.submission_beep_sfx.connect(func():play_blip_sfx(true))

func play_blip_sfx(submission_blip: bool) -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.25
	
	self.stream = generator
	self.play()
	
	var playback: AudioStreamPlayback = self.get_stream_playback()
	if not playback:
		return
	
	var sample_rate: float = generator.mix_rate
	
	var beep_duration: float = 0.12
	var num_frames: int = int(sample_rate * beep_duration)
	
	var target_frequency: float = 120.0
	if submission_blip:
		target_frequency = 160.0
	
	var phase: float = 0.0
	
	for i in range(num_frames):
		var current_frequency: float = target_frequency
		
		var increment: float = current_frequency / sample_rate
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var sample: float = 0.05 if phase < 0.5 else -0.05
		
		var progress: float = float(i) / num_frames
		if progress > 0.95:
			var cutoff_fade: float = lerp(1.0, 0.0, (progress - 0.95)/ 0.05)
			sample *= cutoff_fade 
		playback.push_frame(Vector2(sample, sample))
	
	if submission_blip:
		await get_tree().create_timer(0.1).timeout
		target_frequency /= 2.0
		for i in range(num_frames):
			var current_frequency: float = target_frequency
			
			var increment: float = current_frequency / sample_rate
			phase = wrapf(phase + increment, 0.0, 1.0)
			
			var sample: float = 0.05 if phase < 0.5 else -0.05
			
			var progress: float = float(i) / num_frames
			if progress > 0.95:
				var cutoff_fade: float = lerp(1.0, 0.0, (progress - 0.95)/ 0.05)
				sample *= cutoff_fade 
			playback.push_frame(Vector2(sample, sample))

func start_up_sound() -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 1.2
	
	self.stream = generator
	self.play()
	
	var playback: AudioStreamPlayback = self.get_stream_playback()
	if not playback:
		return
	
	var sample_rate: float = generator.mix_rate
	
	var beep_duration: float = 0.1

	var target_frequency: float = 120.0
	var phase: float = 0.0
	
	play_beep(playback, sample_rate, 80.0, 0.1)
	await get_tree().create_timer(0.2).timeout
	play_beep(playback, sample_rate, 70.0, 0.1)
	await get_tree().create_timer(0.2).timeout
	play_beep(playback, sample_rate, 80.0, 0.1)
	await get_tree().create_timer(0.4).timeout
	play_beep(playback, sample_rate, 100.0, 0.4)

func upgrade_bought_sfx() -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 1.2
	
	self.stream = generator
	self.play()
	
	var playback: AudioStreamPlayback = self.get_stream_playback()
	if not playback:
		return
	
	var sample_rate: float = generator.mix_rate
	
	var beep_duration: float = 0.1
	var num_frames: int = int(sample_rate * beep_duration)
	
	var target_frequency: float = 160.0
	
	var phase: float = 0.0
	
	for i in range(num_frames):
		var current_frequency: float = target_frequency
		
		var increment: float = current_frequency / sample_rate
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var sample: float = 0.05 if phase < 0.5 else -0.05
		
		var progress: float = float(i) / num_frames
		if progress > 0.95:
			var cutoff_fade: float = lerp(1.0, 0.0, (progress - 0.95)/ 0.05)
			sample *= cutoff_fade 
		playback.push_frame(Vector2(sample, sample))
	
	await get_tree().create_timer(0.1).timeout
	
	for i in range(num_frames):
		var current_frequency: float = target_frequency
		
		var increment: float = current_frequency / sample_rate
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var sample: float = 0.05 if phase < 0.5 else -0.05
		
		var progress: float = float(i) / num_frames
		if progress > 0.95:
			var cutoff_fade: float = lerp(1.0, 0.0, (progress - 0.95)/ 0.05)
			sample *= cutoff_fade 
		playback.push_frame(Vector2(sample, sample))
	
	beep_duration = 0.2
	num_frames = int(sample_rate * beep_duration)
	
	target_frequency = 200.0
	
	phase = 0.0
	for i in range(num_frames):
		var current_frequency: float = target_frequency
		
		var increment: float = current_frequency / sample_rate
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var sample: float = 0.05 if phase < 0.5 else -0.05
		
		var progress: float = float(i) / num_frames
		if progress > 0.95:
			var cutoff_fade: float = lerp(1.0, 0.0, (progress - 0.95)/ 0.05)
			sample *= cutoff_fade 
		playback.push_frame(Vector2(sample, sample))

func play_beep(playback: AudioStreamPlayback, sample_rate: float, target_frequency: float, duration: float) -> void:
	var phase: float = 0.0
	var num_frames: int = int(sample_rate * duration)
	for i in range(num_frames):
		var current_frequency: float = target_frequency
		
		var increment: float = current_frequency / sample_rate
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		var sample: float = 0.05 if phase < 0.5 else -0.05
		
		var progress: float = float(i) / num_frames
		if progress > 0.95:
			var cutoff_fade: float = lerp(1.0, 0.0, (progress - 0.95)/ 0.05)
			sample *= cutoff_fade 
		playback.push_frame(Vector2(sample, sample))

func _on_processing_efficiency_button_button_down() -> void:
	upgrade_bought_sfx()


func _on_processing_return_button_button_down() -> void:
	upgrade_bought_sfx()


func _on_average_debt_button_button_down() -> void:
	upgrade_bought_sfx()
