extends Control

@export var menu_scene: Control
@export var game_scene: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_scene.game_quit.connect(_on_quit_to_menu)
	menu_scene.continue_pressed.connect(func():on_play(false))


func _on_quit_to_menu() -> void:
	GameManager.cut_audio.emit()
	var target_colour: Color = Color(0.5,0.5,0.5,0.0)
	var fade_out_tween: Tween = create_tween()
	
	fade_out_tween.tween_property(game_scene, "modulate", target_colour, 1)
	
	await fade_out_tween.finished
	
	fade_out_tween = create_tween()
	game_scene.visible = false
	
	menu_scene.modulate = Color(0.5,0.5,0.5,0.0)
	menu_scene.visible = true
	target_colour = Color.WHITE
	
	menu_scene.hide_screen()
	fade_out_tween.tween_property(menu_scene, "modulate", target_colour, 1)
	
	await fade_out_tween.finished
	await get_tree().create_timer(0.5).timeout
	menu_scene.boot_up_terminal()

func on_play(new_game: bool) -> void:
	GameManager.cut_audio.emit()

	var target_colour: Color = Color(0.5, 0.5, 0.5, 0.0)
	var fade_tween: Tween = create_tween()
	
	fade_tween.tween_property(menu_scene, "modulate", target_colour, 1)
	
	await fade_tween.finished
	
	fade_tween = create_tween()
	menu_scene.visible = false
	
	game_scene.modulate = Color(0.5,0.5,0.5,0.0)
	game_scene.visible = true
	target_colour = Color.WHITE
	
	fade_tween.tween_property(game_scene, "modulate", target_colour, 1)
	GameManager.game_running.emit()
