extends Node2D

@export var obstacle_scene: PackedScene 

# Parâmetros da geração procedural
@export var num_obstacles: int = 15
@export var start_x: float = 400.0
@export var spacing_x: float = 250.0

# Configurações do gap
@export var gap_size: float = 120.0 
@export var min_y: float = 50.0 
@export var max_y: float = 250.0 

# Altura do obstáculo
@export var pipe_height: float = 320.0 

func _ready() -> void:
	# Inicializa a semente aleatória para resultados diferentes a cada jogada
	randomize() 
	generate_level()

func generate_level() -> void:
	if not obstacle_scene:
		push_error("Erro: Cena do obstáculo não atribuída no Inspector do Level!")
		return

	for i in range(num_obstacles):
		# Calcula a posição horizontal (X) deste par de canos
		var current_x = start_x + (i * spacing_x)
		
		# Sorteia a altura (Y) onde ficará o centro do buraco
		var gap_center_y = randf_range(min_y, max_y)
		
		# --- CANO DE CIMA ---
		var top_pipe = obstacle_scene.instantiate()
		add_child(top_pipe)
		
		# Posiciona o cano de cima
		# Subimos a partir do centro do gap (metade do gap + metade do cano)
		top_pipe.position = Vector2(current_x, gap_center_y - (gap_size / 2.0) - (pipe_height / 2.0))
		
		# Inverte o cano de cima verticalmente
		top_pipe.scale.y = -1 
		
		# --- CANO DE BAIXO ---
		var bottom_pipe = obstacle_scene.instantiate()
		add_child(bottom_pipe)
		
		# Posiciona o cano de baixo
		# Descemos a partir do centro do gap
		bottom_pipe.position = Vector2(current_x, gap_center_y + (gap_size / 2.0) + (pipe_height / 2.0))
