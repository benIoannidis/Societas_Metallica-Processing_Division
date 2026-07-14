extends Control

@export var menu_scene: Control
@export var game_scene: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	menu_scene.visible = false
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	game_scene.on_ready()
	game_scene.visible = true
