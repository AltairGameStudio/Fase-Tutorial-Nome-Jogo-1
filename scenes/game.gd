extends Node2D

@onready var camera = $Camera2D
@onready var player = $Player

func _physics_process(delta):
	camera.position.x = player.position.x
