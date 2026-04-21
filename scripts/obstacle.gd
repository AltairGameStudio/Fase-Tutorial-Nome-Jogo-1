extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que colidiu foi o jogador
	if body.name == "Player":
		# Reinicia a fase caso o jogador bata no cano
		get_tree().reload_current_scene()
