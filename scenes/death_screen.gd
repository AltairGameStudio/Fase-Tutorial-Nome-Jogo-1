extends Control

# --- SIGNALS ---
signal retry_level
signal open_config
signal return_to_menu

# --- BUTTON EVENT HANDLERS ---
func _on_resume_released():
	retry_level.emit()

func _on_config_released():
	open_config.emit()

func _on_exit_released():
	return_to_menu.emit()
