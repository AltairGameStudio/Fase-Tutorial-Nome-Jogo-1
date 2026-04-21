extends CanvasLayer

@onready var jump_counter: Label = $JumpCounter

# Esta função será chamada sempre que o jogador saltar
func update_jumps(current_jumps: int) -> void:
	jump_counter.text = "Pulos Restantes: " + str(current_jumps)
