extends Node2D

@export var obstacle_scene: PackedScene 

# Parâmetros da geração procedural
@export var num_obstacles: int = 15
@export var start_x: float = 400.0
@export var spacing_x: float = 300.0

# Configurações do gap
@export var gap_size: float = 200.0 
@export var min_y: float = -100.0
@export var max_y: float = 130.0
@export var max_variation: float = 380.0 # Diferença máxima de altura entre um cano e o seguinte
var last_gap_center: float = 350.0 # Altura inicial

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
		
		# Intervalo seguro baseado no cano anterior
		var safe_min = last_gap_center - max_variation
		var safe_max = last_gap_center + max_variation
		
		# Garante que o intervalo não ultrapasse os limites
		var final_min = clamp(safe_min, min_y, max_y)
		var final_max = clamp(safe_max, min_y, max_y)
		
		# Sorteia a nova altura dentro desse intervalo
		var gap_center_y = randf_range(final_min, final_max)
		
		# Atualiza a variável 
		last_gap_center = gap_center_y
		print("Cano gerado na altura: ", gap_center_y)    
		
		# --- CANO DE CIMA ---
		var top_pipe = obstacle_scene.instantiate()
		add_child(top_pipe)
		
		# Posiciona o cano de cima
		# Subimos a partir do centro do gap (metade do gap + metade do cano)
		top_pipe.position = Vector2(current_x, gap_center_y - (gap_size / 2.0))
		
		# Inverte o cano de cima verticalmente
		top_pipe.scale.y = -1 
		
		# --- CANO DE BAIXO ---
		var bottom_pipe = obstacle_scene.instantiate()
		add_child(bottom_pipe)
		
		# Posiciona o cano de baixo
		# Descemos a partir do centro do gap, metade do vão
		bottom_pipe.position = Vector2(current_x, gap_center_y + (gap_size / 2.0))
