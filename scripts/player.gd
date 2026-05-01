extends CharacterBody2D

const JUMP_VELOCITY = -400.0

@export var max_jumps: int = 100
var jumps_left: int

# Barra de fúria
var jumps_for_rage_counter = 0
const JUMPS_TO_TRIGGER_RAGE = 10
var is_raging = false

@onready var rage_bar = $CanvasLayer/RageBarProgress
@onready var rage_timer = $RageTimer

# Sinal para notificar a UI quando a quantidade de pulos mudar
signal jumps_changed(current_jumps)
signal out_of_jumps()

func _ready() -> void:
	# Inicializa os pulos ao começar a fase
	jumps_left = max_jumps
	jumps_changed.emit(jumps_left)

func _physics_process(delta: float) -> void:
	# Aplica a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Verifica se o jogador apertou o botão de pulo e se ainda tem pulos disponíveis
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		jumps_changed.emit(jumps_left)
		
		if not is_raging:
			jumps_for_rage_counter += 1
			if rage_bar:
				rage_bar.max_value = JUMPS_TO_TRIGGER_RAGE
				rage_bar.value = jumps_for_rage_counter
			
			if jumps_for_rage_counter >= JUMPS_TO_TRIGGER_RAGE:
				initiate_fury()
			
		# Emite um sinal caso os pulos tenham acabado
		if jumps_left == 0:
			out_of_jumps.emit()
			
	if is_raging:
		velocity.x = 350
	else:
		# Mantém a velocidade constante para a direita
		velocity.x = 200
	
	move_and_slide()
	
func initiate_fury():
	is_raging = true
	$AnimatedSprite2D.modulate = Color(1,0,0)
	jumps_for_rage_counter = 0 # Reseta a contagem
	
	if rage_bar:
		rage_bar.value = JUMPS_TO_TRIGGER_RAGE
	
	$RageTimer.start(2.0) # Inicia o tempo de descontrole
	print("FÚRIA!")
	
func _on_rage_timer_timeout ():
	is_raging = false
	$AnimatedSprite2D.modulate = Color(1,1,1)
	if rage_bar:
		rage_bar.value = 0 # Esvazia a barra
		
	print("Fúria passou...")
