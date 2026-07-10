extends Control

@export var praenomia_label: Label
@export var nomia_label: Label
@export var cognomia_label: Label
@export var age_label: Label
@export var debt_label: Label

@export var numus_label: Label
@export var headcount_label: Label
@export var imperium_merit_label: Label

@export var process_button: TextureButton
@export var submit_button: TextureButton

@export var process_button_audio: AudioStreamPlayer

@export var progress_bar: ProgressBar

@export var upgrades_button: TextureButton
@export var processing_screen: TextureRect
@export var upgrade_screen: TextureRect

signal should_iterate_console
signal terminal_beep_sfx
signal submission_beep_sfx

var base_pos: Vector2
func _ready() -> void:
	upgrade_screen.visible = false
	base_pos = position
	
	submit_button.disabled = true
	GameManager.finacial_state_updated.connect(refresh_finacial_data)
	GameManager.active_subject_completed.connect(_on_subject_completion)
	
	process_button.pressed.connect(_on_process_button_pressed)
	submit_button.pressed.connect(_on_submit_button_pressed)
	
	if GameManager.active_subject.is_empty():
		GameManager.request_new_subject()
		update_subject_details()

func refresh_finacial_data() -> void:
	var numus_amount: String = String.num(GameManager.total_numus, 2)
	if GameManager.total_numus > 99.9:
		numus_amount = String.num(GameManager.total_numus, 0)
	numus_label.text = numus_amount
	headcount_label.text = str(GameManager.total_headcount)
	imperium_merit_label.text = str(GameManager.total_imperium_merits)

func update_subject_details() -> void:
	var subject = GameManager.active_subject
	if subject.is_empty(): return
	
	terminal_beep_sfx.emit()
	praenomia_label.text = " " + subject["praenomia"] + " "
	nomia_label.text = " " + subject["nomia"] + " "
	cognomia_label.text = " " + subject["cognomia"] + " "
	
	age_label.text = " " + str(subject["age"]) + " sol years, " + str(subject["month"]) + " months "
	debt_label.text = " NM~" + String.num(subject["debt"], 2) + " "
	
	progress_bar.max_value = subject["assess_steps"]

func enslaved_subject_details() -> void:
	var rand_num: int = randi_range(1, 999999)
	var new_name = "%012d" % rand_num
	
	praenomia_label.text = " " + new_name + " "
	nomia_label.text = " INVALID QUERY "
	cognomia_label.text = " INVALID QUERY "
	age_label.text = " APPROPRIATE WORKING AGE "
	debt_label.text = " NM~" + String.num(GameManager.active_subject["debt"] + 100.0, 2) + " "
	terminal_beep_sfx.emit()

func clear_subject_details() -> void:
	praenomia_label.text = ""
	nomia_label.text = ""
	cognomia_label.text = ""
	age_label.text = ""
	debt_label.text = ""

func _on_submit_button_pressed() -> void:
	submit_button.disabled = true
	process_button.disabled = false
	GameManager.request_new_subject()
	progress_bar.value = 0.0
	clear_subject_details()
	submission_beep_sfx.emit()
	await get_tree().create_timer(1).timeout
	update_subject_details()

func _on_process_button_pressed() -> void:
	process_button_audio.play()
	GameManager.apply_manual_audit_strike()
	execute_screen_shake_fx()
	progress_bar.value = GameManager.active_subject["assess_steps"] - GameManager.active_subject["remaining_assessment"]
	should_iterate_console.emit()

func execute_screen_shake_fx() -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "position", base_pos + Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.03)
	tween.tween_property(self, "position", base_pos + Vector2(randf_range(-2, 2), randf_range(-2, 2)), 0.03)
	tween.tween_property(self, "position", base_pos, 0.04)

func _on_subject_completion() -> void:
	process_button.disabled = true
	submit_button.disabled = false
	enslaved_subject_details()


func _on_texture_button_button_up() -> void:
	if not upgrade_screen.visible:
		open_upgrade_panel()
	else:
		close_upgrade_panel()

func open_upgrade_panel() -> void:
	upgrade_screen.global_position = Vector2(-720, 70)
	
	upgrade_screen.visible = true
	
	var tween: Tween = create_tween().set_parallel(true)
	
	var target_position: Vector2 = Vector2(0, 70)
	
	tween.tween_property(upgrade_screen, "global_position", target_position, 0.45)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_callback(func(): processing_screen.visible = false)

func close_upgrade_panel() -> void:
	processing_screen.visible = true
	var tween: Tween = create_tween().set_parallel(true)
	var target_pos: Vector2 = Vector2(-720, 70)
	
	tween.tween_property(upgrade_screen, "global_position", target_pos, 0.35)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_callback(func(): upgrade_screen.visible = false)
