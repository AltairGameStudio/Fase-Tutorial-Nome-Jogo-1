extends Node2D

@onready var camera = $Camera2D
@onready var player = $Player
@onready var ui = $UI

func _ready() -> void:
	# Ligando o sinal do jogador à função de atualização da interface
	player.jumps_changed.connect(ui.update_jumps)
	
	# Forçando uma primeira atualização para mostrar o valor máximo logo ao início
	ui.update_jumps(player.max_jumps)

func _physics_process(delta: float) -> void:
	camera.position.x = player.position.x
