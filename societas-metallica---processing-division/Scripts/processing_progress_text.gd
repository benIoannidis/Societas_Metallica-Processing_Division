extends TextEdit

@export var terminal_script: Control

var output_order: Array[String] = [
	"> Accessing subject citizen file...", 
	"> file accessed.",
	"> debt collation beginning...", 
	"> collating debt...", 
	"> debt total assessed.",
	"> subject processing complete. preparing for indebted servitude...", 
	"> subject identity stripped, being prepared for indebted servitude.", 
	"> being indebted enslavement process complete."]

var index: int = 0
var console_max_length: int = 300
var active_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_children().size() > 0:
		for child in get_children():
			if child is VScrollBar:
				child.visible = false
				break
	GameManager.active_subject_completed.connect(_on_subject_completed)
	GameManager.new_subject.connect(_on_new_subject)
	terminal_script.should_iterate_console.connect(print_next_line)
	get_v_scroll_bar().modulate.a = 0.0

func animate_top_line(full_new_line: String) -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()
	
	var old_text: String = text.left(console_max_length)
	
	active_tween = create_tween()
	
	var duration: float = full_new_line.length() * 0.01
	
	active_tween.tween_method(
		func(char_count: int):
			var partial_line = full_new_line.left(char_count)
			text = partial_line + "\n" + old_text,
		0,
		full_new_line.length(),
		duration
	).set_trans(Tween.TRANS_LINEAR)

func print_next_line() -> void:
	if not index == 0 and index < 6:
		animate_top_line(output_order[index])
		#var current_text: String = text.left(console_max_length)
		#ext = output_order[index] + "\n" + current_text
		index += 1

func print_line(at_index: int) -> void:
	animate_top_line(output_order[at_index])
	#var current_text: String = text.left(console_max_length)
	#text = output_order[at_index] + "\n" + current_text

func _on_subject_completed() -> void:
	animate_top_line(output_order[6])
	#var current_text: String = text.left(console_max_length)
	#text = output_order[6] + "\n" + current_text

func _on_new_subject() -> void:
	var current_text: String = text.left(console_max_length)
	if not index == 0:
		text = output_order[output_order.size() - 1] + "\n" + current_text
		terminal_script.process_button.disabled = true
		await get_tree().create_timer(1).timeout
		terminal_script.process_button.disabled = false
	current_text = text.left(console_max_length)
	animate_top_line(output_order[0])
	#text = output_order[0] + "\n" + current_text
	index = 1
