extends Node

signal finacial_state_updated
signal active_subject_completed()
signal new_subject
signal toggle_upgrade_screen
signal upgrade_purchased

var total_numus: float = 0.0
var total_headcount: int = 0
var total_imperium_merits: int = 0
var audit_efficiency: float = 1.0
var audit_complete_payout_percentage: float = 0.01
var numus_per_second: float = 0.0

var active_subject: Dictionary = {}

var efficiency_upgrade_cost = 10.0
var return_upgrade_cost = 30.0
var debt_upgrade_cost = 60.0

var efficiency_upgrade_count: int = 0
var return_upgrade_count: int = 0
var debt_upgrade_count: int = 0

func _ready() -> void:
	initialise_tick_timer()

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
	total_numus += payout
	total_headcount += 1
	active_subject_completed.emit()

func request_new_subject() -> void:
	finacial_state_updated.emit()
	var tier: int = 0
	if total_headcount >= 10 and total_headcount < 30:
		tier = 1
	elif total_headcount >= 30 and total_headcount < 75:
		tier = 2
	elif total_headcount >= 75 and total_headcount < 150:
		tier = 3
	
	active_subject = SubjectGenerator.generate_profile(tier)
	new_subject.emit()

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
	SubjectGenerator.average_debt_multiplier += (SubjectGenerator.average_debt_multiplier * 0.5)
	debt_upgrade_cost *= 4
	debt_upgrade_count += 1
	upgrade_purchased.emit()
