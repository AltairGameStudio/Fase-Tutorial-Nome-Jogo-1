extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que colidiu foi o jogador
	if body.name == "Player":
		# Mostra o menu de game over
		body.out_of_jumps.emit()
