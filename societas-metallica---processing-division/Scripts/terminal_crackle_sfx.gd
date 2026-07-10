extends AudioStreamPlayer

@export var max_peak_volume: float = 0.02
@export var crackle_spike_volume: float = 0.05 # The loudness of the sharp clicks/pops
@export var min_time_between_waves: float = 2.5 
@export var max_time_between_waves: float = 6.0 

var playback: AudioStreamPlayback
var time_until_next_wave: float = 0.0
var is_playing_wave: bool = false
var wave_frames_total: int = 0
var wave_frames_left: int = 0

var last_sample_value: float = 0.0
var base_filter_blend: float = 0.3

func _ready() -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.2
	
	self.stream = generator
	self.play()
	
	playback = self.get_stream_playback()
	_determine_next_wave_time()

func _process(delta: float) -> void:
	if not playback:
		return
		
	var frames_available = playback.get_frames_available()
	if frames_available == 0:
		return

	if not is_playing_wave:
		time_until_next_wave -= delta
		if time_until_next_wave <= 0.0:
			is_playing_wave = true
			
			var wave_duration = randf_range(0.45, 0.95)
			wave_frames_total = int(44100 * wave_duration)
			wave_frames_left = wave_frames_total
			
			base_filter_blend = randf_range(0.25, 0.45)
	
	for i in range(frames_available):
		var sample: float = 0.0
		
		if is_playing_wave and wave_frames_left > 0:
			var raw_white_noise = randf_range(-1.0, 1.0)
			var progress: float = 1.0 - (float(wave_frames_left) / float(wave_frames_total))
			
			var dynamic_pitch_mod = sin(progress * PI) * 0.15
			var active_filter_blend = clamp(base_filter_blend + dynamic_pitch_mod, 0.1, 0.8)
			
			# 1. Generate the base filtered white noise wave
			last_sample_value = lerp(last_sample_value, raw_white_noise, active_filter_blend)
			var normalized_sample = clamp(last_sample_value, -1.0, 1.0)
			
			var envelope_volume = sin(progress * PI)
			var wave_component = normalized_sample * (envelope_volume * max_peak_volume)
			
			# 2. ADD THE CRACKLE POP COMPONENT
			# Roll a dice for an ultra-rare chance per frame (e.g., 0.15% chance per frame) to spark
			var crackle_component: float = 0.0
			if randf() > 0.9985:
				# Sharp, unfiltered, high-amplitude spike
				crackle_component = randf_range(-1.0, 1.0) * crackle_spike_volume
			
			# Scale the crackle loudness to the envelope so pops fade out naturally with the wave
			crackle_component *= envelope_volume
			
			# 3. Mix components together
			sample = wave_component + crackle_component
			
			wave_frames_left -= 1
			
			if wave_frames_left <= 0:
				is_playing_wave = false
				_determine_next_wave_time()
		
		playback.push_frame(Vector2(sample, sample))

func _determine_next_wave_time() -> void:
	time_until_next_wave = randf_range(min_time_between_waves, max_time_between_waves)
