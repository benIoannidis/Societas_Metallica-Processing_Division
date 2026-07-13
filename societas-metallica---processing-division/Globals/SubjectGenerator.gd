extends Node

var praenomia: PackedStringArray = []
var nomia: PackedStringArray = []
var cognomia: PackedStringArray = []

var average_debt_multiplier: float = 1.0

func _ready() -> void:
	load_census_database()

func load_census_database() -> void:
	var file_path = "res://Data/roman_names.txt"
	if not FileAccess.file_exists(file_path):
		printerr("CRITICAL FAILURE: Roman data ledger missing at path: ", file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var current_section: String = ""
	
	while file.get_position() < file.get_length():
		var line = file.get_line().strip_edges()
		if line.is_empty():
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line
			continue
		
		var entries = line.split(",", false)
		for entry in entries:
			var clean_entry = entry.strip_edges()
			match current_section:
				"[PRAENOMEN]": praenomia.append(clean_entry)
				"[NOMEN]": nomia.append(clean_entry)
				"[COGNOMEN]": cognomia.append(clean_entry)

func generate_profile(tier: int) -> Dictionary:
	if praenomia.is_empty() or nomia.is_empty() or cognomia.is_empty():
		push_error("Census database accessed before structural parsing array init.")
		return {"praenomia": "Unknown", "nomia": "Subject", "cognomia": "---", "age": 21, 
		"month": 0, "debt": 100.0, "assess_steps": 10.0, "remaining_assessment": 10.0}
	
	var p = praenomia[randi() % praenomia.size()]
	var n = nomia[randi() % nomia.size()]
	var c = cognomia[randi() % cognomia.size()]
	
	var minimum_debt = 50.0 * pow(1.5, tier) * average_debt_multiplier
	var maximum_debt = 150.0 * pow(1.5, tier) * average_debt_multiplier
	var rolled_debt = randf_range(minimum_debt, maximum_debt)
	
	var minimum_steps = 3.0 * pow(2, tier)
	var maximum_steps = 10.0 * pow(2, tier)
	var rolled_steps = randf_range(minimum_steps, maximum_steps)
	
	var rolled_age = randi_range(8, 58)
	var rolled_month = randi_range(0, 11)
	
	return {"praenomia": p, "nomia": n, "cognomia": c, "age": rolled_age, "month": rolled_month,
		"debt": rolled_debt, "assess_steps": rolled_steps, "remaining_assessment": rolled_steps}
