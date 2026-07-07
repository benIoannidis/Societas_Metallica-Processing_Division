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

@export var progress_bar: ProgressBar

signal should_iterate_console

func _ready() -> void:
	submit_button.disabled = true
	GameManager.finacial_state_updated.connect(refresh_finacial_data)
	GameManager.active_subject_completed.connect(_on_subject_completion)
	
	process_button.pressed.connect(_on_process_button_pressed)
	submit_button.pressed.connect(_on_submit_button_pressed)
	
	if GameManager.active_subject.is_empty():
		GameManager.request_new_subject()
		update_subject_details()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Process") and not process_button.disabled:
		_on_process_button_pressed()
	if Input.is_action_just_pressed("Submit") and not submit_button.disabled:
		_on_submit_button_pressed()

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
	
	praenomia_label.text = " " + subject["praenomia"] + " "
	nomia_label.text = " " + subject["nomia"] + " "
	cognomia_label.text = " " + subject["cognomia"] + " "
	
	age_label.text = " " + str(subject["age"]) + " sol years, " + str(subject["month"]) + " months "
	debt_label.text = " NM~" + String.num(subject["debt"], 2) + " "
	
	progress_bar.max_value = subject["assess_steps"]

func _on_submit_button_pressed() -> void:
	submit_button.disabled = true
	process_button.disabled = false
	GameManager.request_new_subject()
	update_subject_details()
	progress_bar.value = 0.0

func _on_process_button_pressed() -> void:
	GameManager.apply_manual_audit_strike()
	execute_screen_shake_fx()
	progress_bar.value = GameManager.active_subject["assess_steps"] - GameManager.active_subject["remaining_assessment"]
	should_iterate_console.emit()

func execute_screen_shake_fx() -> void:
	var tween = create_tween()
	var base_pos = position
	
	tween.tween_property(self, "position", base_pos + Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.03)
	tween.tween_property(self, "position", base_pos + Vector2(randf_range(-2, 2), randf_range(-2, 2)), 0.03)
	tween.tween_property(self, "position", base_pos, 0.04)

func _on_subject_completion() -> void:
	process_button.disabled = true
	submit_button.disabled = false
