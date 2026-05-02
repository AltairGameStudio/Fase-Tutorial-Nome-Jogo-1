extends Control

signal start_game

func _on_play_button_pressed():
	start_game.emit()

func _on_config_button_pressed():
	$Start.hide()
	$Start.process_mode = Node.PROCESS_MODE_DISABLED
	
	$Settings.show()
	await get_tree().create_timer(0.3).timeout
	
	$Settings.process_mode = Node.PROCESS_MODE_INHERIT

func _on_quit_button_pressed():
	get_tree().quit()

func show_menu():
	$Settings.hide()
	$Settings.process_mode = Node.PROCESS_MODE_DISABLED
		
	$Start.show()
	$Start.process_mode = Node.PROCESS_MODE_INHERIT
