extends TextureRect

@onready var regular_upgrades: TextureRect = $CanvasGroup/UpgradesScreen
@onready var prestige_upgrades: TextureRect = $CanvasGroup/PrestigeStoreScreen
@onready var prestige_toggle_button_panel: TextureRect = $TextureRect
@onready var prestige_upgrade_toggle: TextureButton = $TextureRect/PrestigeStore
@onready var upgrade_button_audio: AudioStreamPlayer = $"../../UpgradeButtonAudio"

@export var prestige_button_textures: Array[Texture2D]
@export var back_button_textures: Array[Texture2D]

func on_ready() -> void:
	regular_upgrades.visible = true
	prestige_upgrades.visible = false
	
	if GameManager.claimed_merits > 0 or GameManager.total_imperium_merits > 0:
		prestige_toggle_button_panel.visible = true
	else:
		prestige_toggle_button_panel.visible = false

func _ready() -> void:
	GameManager.game_running.connect(on_ready)

func _on_prestige_store_button_up() -> void:
	if regular_upgrades.visible:
		regular_upgrades.visible = false
		prestige_upgrades.visible = true
		swap_button_textures(back_button_textures)
	else:
		regular_upgrades.visible = true
		prestige_upgrades.visible = false
		swap_button_textures(prestige_button_textures)

func swap_button_textures(new_textures: Array[Texture2D]) -> void:
	prestige_upgrade_toggle.texture_normal = new_textures[0]
	prestige_upgrade_toggle.texture_pressed = new_textures[1]
	prestige_upgrade_toggle.texture_hover = new_textures[2]


func _on_prestige_store_button_down() -> void:
	upgrade_button_audio.play()
