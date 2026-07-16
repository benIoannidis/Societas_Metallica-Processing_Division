extends Control

func _on_processing_efficiency_button_button_up() -> void:
	GameManager.upgrade_efficiency()

func _on_processing_return_button_button_up() -> void:
	GameManager.upgrade_return()

func _on_average_debt_button_button_up() -> void:
	GameManager.upgrade_average_debt()

func _on_prestige_button_button_up() -> void:
	GameManager.perform_prestige()
