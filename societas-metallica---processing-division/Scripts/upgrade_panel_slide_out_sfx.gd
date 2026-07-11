extends AudioStreamPlayer

@export var scraping_volume: float = 0.04
@export var click_volume: float = 0.05

func play_slide_open_sfx() -> void:
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.6
	
	self.stream = generator
	self.play()
	
	var playback = self.get_stream_playback()
	if not playback: return
	
	var sample_rate = generator.mix_rate
	var slide_duration = 0.42
	var num_frames = int(sample_rate * slide_duration)
	
	var last_sample = 0.0
	var phase = 0.0
	
	# 1. THE HEAVY METAL-ON-METAL FRICTION SLIDE
	for i in range(num_frames):
		var progress = float(i) / num_frames
		
		# Generate raw texture friction using white noise
		var raw_noise = randf_range(-1.0, 1.0)
		
		# RESONANT BANDPASS FILTER:
		# We shift the filter blend dynamically. As the screen opens, the hollow 
		# "ringing" frequency of the metal plate pitches downward from screechy to heavy.
		var filter_cutoff = lerp(0.25, 0.12, progress)
		last_sample = lerp(last_sample, raw_noise, filter_cutoff)
		
		# FRICTION TREMOR STUTTER:
		# Metal sliding isn't perfectly smooth; it catches and vibrates.
		# We use a rapid sine modulator (80Hz) to violently stutter the volume.
		var friction_stutter = 0.7 + (sin(progress * num_frames * 0.01) * 0.3)
		
		# Linear fade down as the slide loses momentum near the end of the track
		var rail_fade = 1.0 - progress
		
		var sample = last_sample * scraping_volume * friction_stutter * rail_fade
		playback.push_frame(Vector2(sample, sample))
		
	# 2. THE SOLID IRON IMPACT DEAD-BOLT CLICK
	# A heavy mechanical thud to indicate the sliding plate locking home
	var click_duration = 0.04
	var click_frames = int(sample_rate * click_duration)
	var click_last_sample = 0.0
	
	for i in range(click_frames):
		var progress = float(i) / click_frames
		var raw_noise = randf_range(-1.0, 1.0)
		
		# A deep, muffled low-pass filter to give the click weight and bass thump
		click_last_sample = lerp(click_last_sample, raw_noise, 0.05)
		
		# Sharp decaying exponential envelope for an immediate impact impact
		var envelope = exp(-progress * 8.0)
		var sample = click_last_sample * click_volume * envelope
		
		playback.push_frame(Vector2(sample, sample))


func play_slide_close_sfx() -> void:
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.6
	
	self.stream = generator
	self.play()
	
	var playback = self.get_stream_playback()
	if not playback: return
	
	var sample_rate = generator.mix_rate
	
	# 1. THE UNLATCH SPRING POPS
	# A quick sharp release pop right before the plate begins traveling back
	var unclick_duration = 0.02
	var unclick_frames = int(sample_rate * unclick_duration)
	for i in range(unclick_frames):
		var progress = float(i) / unclick_frames
		var sample = randf_range(-0.5, 0.5) * click_volume * (1.0 - progress)
		playback.push_frame(Vector2(sample, sample))
		
	# 2. THE REVERSE METAL RETRACTION SCRAPE
	var slide_duration = 0.38
	var num_frames = int(sample_rate * slide_duration)
	var last_sample = 0.0
	
	for i in range(num_frames):
		var progress = float(i) / num_frames
		var raw_noise = randf_range(-1.0, 1.0)
		
		# The pitch slides slightly *upward* this time as the plate gains speed winding back
		var filter_cutoff = lerp(0.14, 0.22, progress)
		last_sample = lerp(last_sample, raw_noise, filter_cutoff)
		
		# High-frequency structural rattle modulator
		var vibration = 0.7 + (sin(progress * num_frames * 0.015) * 0.3)
		
		# Bell curve envelope: swells up as it leaves the housing, fades out as it completes retraction
		var envelope = sin(progress * PI)
		
		var sample = last_sample * scraping_volume * vibration * envelope
		playback.push_frame(Vector2(sample, sample))
