extends TextureButton

var audio_bus_index: int = AudioServer.get_bus_index("Master")

@export var unmuted_button_sprite: Texture2D
@export var muted_button_sprite: Texture2D

var audio_muted: bool = false

func _on_button_up() -> void:
	audio_muted = not audio_muted
	
	if audio_muted:
		texture_normal = muted_button_sprite
	else:
		texture_normal = unmuted_button_sprite
	
	AudioServer.set_bus_mute(audio_bus_index, audio_muted)
