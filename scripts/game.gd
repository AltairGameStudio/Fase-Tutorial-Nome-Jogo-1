extends Node2D

@onready var camera = $Camera2D
@onready var player = $Player
@onready var ui = $UI
@onready var game_over_screen = $CanvasLayer/GameOver

func _ready() -> void:
	# Conecta o sinal do player à função que mostra o menu
	$Player.out_of_jumps.connect(_on_player_out_of_jumps)
	
	# Ligando o sinal do jogador à função de atualização da interface
	player.jumps_changed.connect(ui.update_jumps)
	
	# Forçando uma primeira atualização para mostrar o valor máximo logo ao início
	ui.update_jumps(player.max_jumps)

func _physics_process(delta: float) -> void:
	camera.position.x = player.position.x

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_game_over()

func _on_ground_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Galinha bateu no chão!")
		show_game_over()

func _on_player_out_of_jumps():
	show_game_over()

func show_game_over():
	$CanvasLayer/GameOver.show() # Mostra o menu
	get_tree().paused = true # Pausa o jogo

func game_over():
	game_over_screen.show() # Mostra o menu
	get_tree().paused = true # Pausa o jogo

func _on_button_restart_pressed() -> void:
	get_tree().paused = false # Despausa
	get_tree().reload_current_scene() # Recarrega a fase
