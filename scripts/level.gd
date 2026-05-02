extends Node2D

# --- SINAIS NECESSÁRIOS PARA O MAIN ---
signal player_death
signal level_completed

@export var obstacle_scene: PackedScene 

# Parâmetros da geração procedural
@export var num_obstacles: int = 15
@export var start_x: float = 400.0
@export var spacing_x: float = 300.0

# Configurações do gap
@export var gap_size: float = 200.0 
@export var min_y: float = -100.0
@export var max_y: float = 130.0
@export var max_variation: float = 380.0 
var last_gap_center: float = 350.0 

@export var pipe_height: float = 320.0 

func _ready() -> void:
	randomize() 
	generate_level()

func generate_level() -> void:
	if not obstacle_scene:
		push_error("Erro: Cena do obstáculo não atribuída no Inspector do Level!")
		return

	for i in range(num_obstacles):
		var current_x = start_x + (i * spacing_x)
		
		var safe_min = last_gap_center - max_variation
		var safe_max = last_gap_center + max_variation
		
		var final_min = clamp(safe_min, min_y, max_y)
		var final_max = clamp(safe_max, min_y, max_y)
		
		var gap_center_y = randf_range(final_min, final_max)
		last_gap_center = gap_center_y
		
		# --- CANO DE CIMA ---
		var top_pipe = obstacle_scene.instantiate()
		add_child(top_pipe)
		top_pipe.position = Vector2(current_x, gap_center_y - (gap_size / 2.0))
		top_pipe.scale.y = -1 
		
		# Conecta o sinal de colisão do cano (assumindo que o cano tem um sinal "body_entered")
		# Substitua "body_entered" pelo nome do sinal real que o seu obstáculo emite se for diferente
		if top_pipe.has_signal("body_entered"):
			top_pipe.body_entered.connect(_on_obstacle_body_entered)
		
		# --- CANO DE BAIXO ---
		var bottom_pipe = obstacle_scene.instantiate()
		add_child(bottom_pipe)
		bottom_pipe.position = Vector2(current_x, gap_center_y + (gap_size / 2.0))
		
		# Conecta o sinal de colisão do cano de baixo também
		if bottom_pipe.has_signal("body_entered"):
			bottom_pipe.body_entered.connect(_on_obstacle_body_entered)


# --- FUNÇÕES DE DETECÇÃO DE MORTE ---

# 1. Quando o jogador bate em um cano instanciado
func _on_obstacle_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_death.emit() # Avisa o Main para dar Game Over

# 2. Quando o jogador bate no chão (Você precisa ter um Area2D chamado "GroundArea" na sua cena do Level)
func _on_ground_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Galinha bateu no chão!")
		player_death.emit() # Avisa o Main para dar Game Over

func _on_ceiling_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_death.emit() # Avisa o Main para dar Game Over

func _on_finish_line_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Fase concluída!")
		level_completed.emit() # Avisa o Main para passar de fase
