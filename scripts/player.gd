extends CharacterBody2D

const JUMP_VELOCITY = -300.0

@export var max_jumps: int = 10
var jumps_left: int

# Sinal para notificar a UI quando a quantidade de pulos mudar
signal jumps_changed(current_jumps)
signal out_of_jumps()

func _ready() -> void:
	# Inicializa os pulos ao começar a fase
	jumps_left = max_jumps
	jumps_changed.emit(jumps_left)

func _physics_process(delta: float) -> void:
	# Aplica a gravidade
	velocity += get_gravity() * delta

	# Verifica se o jogador apertou o botão de pulo e se ainda tem pulos disponíveis
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		jumps_changed.emit(jumps_left)
		
		# Emite um sinal caso os pulos tenham acabado
		if jumps_left == 0:
			out_of_jumps.emit()

	# Mantém a velocidade constante para a direita
	velocity.x = 200

	move_and_slide()
