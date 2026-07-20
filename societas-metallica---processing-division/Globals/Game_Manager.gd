extends Node

signal finacial_state_updated
signal active_subject_completed()
signal new_subject
signal toggle_upgrade_screen
signal upgrade_purchased
signal cut_audio
signal can_prestige
signal prestige_performed
signal game_running
signal menu_open

var save_exists: bool = false

var total_numus: float = 0.0
var total_headcount: int = 0
var lifetime_headcount: int = 0
var total_imperium_merits: int = 0
var audit_efficiency: float = 1.0
var audit_complete_payout_percentage: float = 0.01
var numus_per_second: float = 0.0

# --- merits calc ---
const BASE_MERIT_COST: float = 100.0
const SCALE_EXPONENT: float = 1.5

var claimed_merits: int = 0

var active_subject: Dictionary = {}

# --- run upgrades ---
var efficiency_upgrade_cost: float = 10.0
var return_upgrade_cost: float = 30.0
var debt_upgrade_cost: float = 60.0

var efficiency_upgrade_count: int = 0
var return_upgrade_count: int = 0
var debt_upgrade_count: int = 0

# --- merit upgrades ---
var automation_merit_cost: int = 1
var passive_merit_cost: int = 2
var multiplier_merit_cost: int = 1

var automation_speed_level: int = 0
var passive_numus_level: int = 0
var multiplier_level: int = 0
var data_bus_multiplier: float = 1.0 # numus gains multiplier

var save_path: String = "user://save/save.dat"

func _ready() -> void:
	initialise_tick_timer()
	load_game()
	finacial_state_updated.emit()
	await get_tree().create_timer(1.5).timeout
	menu_open.emit()

func initialise_tick_timer() -> void:
	var tick_timer = Timer.new()
	tick_timer.wait_time = 0.1
	tick_timer.autostart = true
	tick_timer.timeout.connect(_on_economic_tick)
	add_child(tick_timer)

func _on_economic_tick() -> void:
	if numus_per_second > 0.0:
		total_numus += (numus_per_second * 0.1)
		finacial_state_updated.emit()
	if automation_speed_level > 0:
		for i in range(automation_speed_level):
			apply_manual_audit_strike()
			if active_subject["remaining_assessment"] <= 0.0:
				request_new_subject()

func apply_manual_audit_strike() -> void:
	if active_subject.is_empty():
		return
	
	active_subject["remaining_assessment"] -= audit_efficiency
	
	if active_subject["remaining_assessment"] <= 0.0:
		finalise_active_subject()
	else:
		finacial_state_updated.emit()

func finalise_active_subject() -> void:
	var payout = (active_subject["debt"] * audit_complete_payout_percentage)
	total_numus += payout * data_bus_multiplier
	total_headcount += 1
	active_subject_completed.emit()

func request_new_subject() -> void:
	finacial_state_updated.emit()
	var tier: int = 0
	if total_headcount >= 10 and total_headcount < 30: 			tier = 1
	elif total_headcount >= 30 and total_headcount < 75: 		tier = 2
	elif total_headcount >= 75 and total_headcount < 150: 		tier = 3
	elif total_headcount >= 150 and total_headcount < 300: 		tier = 4
	elif total_headcount >= 300 and total_headcount < 450: 		tier = 5
	elif total_headcount >= 450 and total_headcount < 600:		tier = 6
	
	active_subject = SubjectGenerator.generate_profile(tier)
	new_subject.emit()
	
	if get_pending_merits() > 0:
		can_prestige.emit()

func upgrade_automation() -> void:
	automation_speed_level += 1
	automation_merit_cost = pow(float(passive_numus_level + 1), 2)
	upgrade_purchased.emit()

func upgrade_passive() -> void:
	passive_numus_level += 1
	passive_merit_cost = pow(float(passive_numus_level + 1), 2)
	numus_per_second += pow(float(passive_numus_level), 2)
	upgrade_purchased.emit()

func upgrade_multiplier() -> void:
	multiplier_level += 1
	data_bus_multiplier = multiplier_level + (multiplier_level * 0.5)
	multiplier_merit_cost = multiplier_merit_cost + (multiplier_level * 0.75)
	upgrade_purchased.emit()

func upgrade_efficiency() -> void:
	total_numus -= efficiency_upgrade_cost
	audit_efficiency += (audit_efficiency * 0.1)
	efficiency_upgrade_cost += (efficiency_upgrade_cost * 0.5)
	efficiency_upgrade_count += 1
	upgrade_purchased.emit()

func upgrade_return() -> void:
	total_numus -= return_upgrade_cost
	audit_complete_payout_percentage *= 2.0
	return_upgrade_cost *= 4.0
	return_upgrade_count += 1
	upgrade_purchased.emit()

func upgrade_average_debt() -> void:
	total_numus -= debt_upgrade_cost
	SubjectGenerator.average_debt_multiplier *= 1.5
	debt_upgrade_cost *= 4.0
	debt_upgrade_count += 1
	upgrade_purchased.emit()

func upgrades_from_load() -> void:
	for i in range(0,efficiency_upgrade_count):
		audit_efficiency += (audit_efficiency * 0.1)
	
	for i in range(0,return_upgrade_count):
		audit_complete_payout_percentage *= 2.0
	
	for i in range(0, debt_upgrade_count):
		SubjectGenerator.average_debt_multiplier *= 1.5
	
	for i in range(0, automation_speed_level):
		automation_merit_cost = pow(float(passive_numus_level + 1), 2)
	
	for i in range(0, passive_numus_level):
		passive_merit_cost = pow(float(passive_numus_level + 1), 2)
		numus_per_second += pow(float(passive_numus_level), 2)
	
	for i in range(0, multiplier_level):
		data_bus_multiplier = multiplier_level + (multiplier_level * 0.5)
		multiplier_merit_cost = multiplier_merit_cost + (multiplier_level * 0.75)

func get_total_merits_earned_for_lifetime_count(headcount: int) -> int:
	if headcount < BASE_MERIT_COST:
		return 0
	return int(pow(float(headcount)/ BASE_MERIT_COST, 1.0 / SCALE_EXPONENT)) - claimed_merits

func get_pending_merits() -> int:
	var potential_lifetime: int = lifetime_headcount + total_headcount
	var target_total: int = get_total_merits_earned_for_lifetime_count(potential_lifetime)
	
	return max(0, target_total - total_imperium_merits)

func perform_prestige() -> void:
	var pending: int = get_pending_merits()
	if pending <= 0:
		return
	total_imperium_merits += pending
	claimed_merits += pending
	lifetime_headcount += total_headcount
	
	total_numus = 0.0 
	total_headcount = 0
	
	efficiency_upgrade_count = 0
	efficiency_upgrade_cost = 10.0
	return_upgrade_count = 0
	return_upgrade_cost = 30.0
	debt_upgrade_count = 0
	debt_upgrade_cost = 60.0
	
	save_game()
	
	request_new_subject()
	
	finacial_state_updated.emit()
	
	prestige_performed.emit()

func clear_save() -> void:
	var dir_path = save_path.get_base_dir()
	if DirAccess.dir_exists_absolute(dir_path):
		DirAccess.remove_absolute(save_path)
		total_numus = 0.0
		total_headcount = 0
		lifetime_headcount = 0
		total_imperium_merits = 0
		audit_efficiency = 1.0
		audit_complete_payout_percentage = 0.01
		numus_per_second = 0.0
		
		efficiency_upgrade_cost = 10.0
		return_upgrade_cost = 30.0
		debt_upgrade_cost = 60.0
		
		efficiency_upgrade_count = 0
		return_upgrade_count = 0
		debt_upgrade_count = 0
		
		claimed_merits = 0
		# --- merit upgrades ---
		automation_merit_cost = 1
		passive_merit_cost = 2
		multiplier_merit_cost = 1
		automation_speed_level = 0
		passive_numus_level = 0
		multiplier_level = 0
		data_bus_multiplier = 1.0 # numus gains multiplier
		
		active_subject.clear()
		save_game()

func save_game() -> void:
	var dir_path = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	print(dir_path)
	var file_access: FileAccess = FileAccess.open(save_path,FileAccess.WRITE)
	file_access.store_var(total_numus)
	file_access.store_var(total_headcount)
	file_access.store_var(lifetime_headcount)
	file_access.store_var(total_imperium_merits)
	file_access.store_var(efficiency_upgrade_count)
	file_access.store_var(efficiency_upgrade_cost)
	file_access.store_var(return_upgrade_count)
	file_access.store_var(return_upgrade_cost)
	file_access.store_var(debt_upgrade_count)
	file_access.store_var(debt_upgrade_cost)
	
	file_access.store_var(claimed_merits)
	file_access.store_var(automation_speed_level)
	file_access.store_var(passive_numus_level)
	file_access.store_var(multiplier_level)
	file_access.close()
	
	save_exists = true

func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		save_game()
		return
	else:
		save_exists = true
	
	var file_access: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file_access:
		total_numus = file_access.get_var()
		total_headcount = file_access.get_var()
		lifetime_headcount = file_access.get_var()
		total_imperium_merits = file_access.get_var()
		
		efficiency_upgrade_count = file_access.get_var()
		efficiency_upgrade_cost = file_access.get_var()
		return_upgrade_count = file_access.get_var()
		return_upgrade_cost = file_access.get_var()
		debt_upgrade_count = file_access.get_var()
		debt_upgrade_cost = file_access.get_var()
		
		claimed_merits = file_access.get_var()
		automation_speed_level = file_access.get_var()
		passive_numus_level = file_access.get_var()
		multiplier_level = file_access.get_var()
		
		file_access.close()
		
		upgrades_from_load()
