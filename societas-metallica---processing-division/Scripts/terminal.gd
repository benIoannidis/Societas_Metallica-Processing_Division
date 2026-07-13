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
@export var upgrade_button_audio: AudioStreamPlayer

@export var processing_screen: TextureRect
@export var upgrade_screen: TextureRect
@export var upgrade_screen_sfx: AudioStreamPlayer

@export var efficiency_button: TextureButton
@export var efficiency_label: Label
@export var efficiency_count_label: Label
@export var return_button: TextureButton
@export var return_label: Label
@export var return_count_label: Label
@export var debtupgrade_button: TextureButton
@export var debtupgrade_label: Label
@export var debt_count_label: Label
@export var prestige_button: TextureButton
@export var prestige_label: Label

signal should_iterate_console
signal terminal_beep_sfx
signal submission_beep_sfx

var base_pos: Vector2
func _ready() -> void:
	set_default_upgrade_values()
	upgrade_screen.visible = false
	base_pos = position
	
	submit_button.disabled = true
	GameManager.finacial_state_updated.connect(refresh_finacial_data)
	GameManager.active_subject_completed.connect(_on_subject_completion)
	GameManager.upgrade_purchased.connect(
		func(): 
		refresh_finacial_data()
		update_upgrade_buttons()
		)
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
	process_button_audio.play()
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

func _on_upgrades_button_button_down() -> void:
	upgrade_button_audio.play()

func _on_texture_button_button_up() -> void:
	
	if not upgrade_screen.visible:
		open_upgrade_panel()
	else:
		close_upgrade_panel()

func open_upgrade_panel() -> void:
	update_upgrade_buttons()
	upgrade_screen.global_position = Vector2(-720, 70)
	
	upgrade_screen.visible = true
	
	upgrade_screen_sfx.play_slide_open_sfx()
	
	var tween: Tween = create_tween().set_parallel(true)
	
	var target_position: Vector2 = Vector2(0, 70)
	
	tween.tween_property(upgrade_screen, "global_position", target_position, 0.45)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_callback(func(): processing_screen.visible = false)

func close_upgrade_panel() -> void:
	processing_screen.visible = true
	
	upgrade_screen_sfx.play_slide_close_sfx()
	
	var tween: Tween = create_tween().set_parallel(true)
	var target_pos: Vector2 = Vector2(-720, 70)
	
	tween.tween_property(upgrade_screen, "global_position", target_pos, 0.35)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_callback(func(): upgrade_screen.visible = false)

func _on_exit_button_button_down() -> void:
	upgrade_button_audio.play()

func _on_exit_button_button_up() -> void:
	#replace later 
	get_tree().quit()

func set_default_upgrade_values() -> void:
	efficiency_button.disabled = true
	return_button.disabled = true
	debtupgrade_button.disabled = true
	prestige_button.disabled = true
	
	efficiency_count_label.text = "x0"
	efficiency_label.text = "NM 10.00"
	return_count_label.text = "x0"
	return_label.text = "NM 30.00"
	debt_count_label.text = "x0"
	debtupgrade_label.text = "NM 60.00"
	prestige_label.text = "M̶ 0"

func update_upgrade_buttons() -> void:
	efficiency_button.disabled = GameManager.total_numus < GameManager.efficiency_upgrade_cost
	return_button.disabled = GameManager.total_numus < GameManager.return_upgrade_cost
	debtupgrade_button.disabled = GameManager.total_numus < GameManager.debt_upgrade_cost
	
	efficiency_count_label.text = "x" + str(GameManager.efficiency_upgrade_count)
	efficiency_label.text = "NM " + str(GameManager.efficiency_upgrade_cost)
	return_count_label.text = "x" + str(GameManager.return_upgrade_count)
	return_label.text = "NM " + str(GameManager.return_upgrade_cost)
	debt_count_label.text = "x" + str(GameManager.debt_upgrade_count)
	debtupgrade_label.text = "NM " + str(GameManager.debt_upgrade_cost)
