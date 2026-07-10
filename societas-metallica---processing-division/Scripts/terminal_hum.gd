extends AudioStreamPlayer

@export var hum_volume: float = 0.02
@export var base_frequency: float = 50.0
@export var oscillation_speed = 3.0

var playback: AudioStreamPlayback
var phase: float = 0.0
var time_elapsed: float = 0.0

func _ready() -> void:
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.5 # A slightly larger buffer keeps playback smooth
	
	self.stream = generator
	self.play()
	
	playback = self.get_stream_playback()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not playback:
		return
		
	time_elapsed += delta
	
	# 2. Keep checking how many free slots are available in the audio buffer
	var frames_available = playback.get_frames_available()
	
	oscillation_speed = randf_range(2.0, 4.0)
	# Fill the empty buffer space on the fly
	for i in range(frames_available):
		# Create an oscillation (LFO) using a sine wave over time
		# This subtly swings the pitch up and down by 2.5 Hz to simulate voltage fluctuations
		var pitch_wobble = sin(time_elapsed * oscillation_speed) * 2.5
		var current_frequency = base_frequency + pitch_wobble
		
		# Advance the wave phase
		var increment = current_frequency / 44100.0
		phase = wrapf(phase + increment, 0.0, 1.0)
		
		# --- MULTI-WAVE BUZZ MATH ---
		# A pure sine wave is too clean. By mixing a smooth sine wave with a harsh square wave, 
		# we get that perfect harsh "electrical transformer rattling against metal" timbre.
		var sine_component = sin(phase * (PI * 2))
		var square_component = 0.3 if phase < 0.5 else -0.3
		
		var sample = (sine_component * 0.7) + (square_component * 0.3)
		
		# Apply the volume and add a tiny volume wobble so the loudness breathes slightly too
		var volume_wobble = 1.0 + (sin(time_elapsed * 1.5) * 0.1)
		sample *= hum_volume * volume_wobble
		
		# Feed it into the continuous live buffer
		playback.push_frame(Vector2(sample, sample))
