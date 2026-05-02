extends Node2D

# --- CONSTANTS ---
const LEVEL_BUTTON = preload("res://scenes/level_button.tscn")
const MUSIC = preload("res://assets/Music/musica_normal.wav")
const MAD_MUSIC = preload("res://assets/Music/musica_puto.wav")

const MAX_LEVELS_PER_ROW = 3
const TRANSITION_DURATION = 1.0
const CAMERA_DEFAULT_ZOOM = 1.0
const CAMERA_ZOOM_IN = 2.0
const PAN_SPEED = 800.0 

# --- VARIABLES ---
var currentLevel = 0
@export var levels: Array[PackedScene] = []

var level: Node2D
var player: Node2D

var camera_shifted = false
var camera_start_x = 0.0
var default_camera_position := Vector2.ZERO
var current_camera_position := Vector2.ZERO
		
@onready var currentLevelPath = "res://fases/fase_6.tscn"

var numDeaths = 0
var level_creating = false
var storedPlayerCollages = []

@onready var status = $Camera2D/Status
@onready var death_screen = $CanvasLayer/DeathScreen
@onready var music_player = $MusicPlayer

# --- INITIALIZATION ---
func _ready():
	# CRITICAL 1: Main must ALWAYS process so Tweens run even when the game is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS 
	
	$Menu.show()
	
	death_screen.hide()
	death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	
	death_screen.retry_level.connect(_on_death_screen_retry)
	death_screen.return_to_menu.connect(_on_death_screen_exit)
	
	music_player.stream = MUSIC
	music_player.play()

	default_camera_position = $Camera2D.global_position
	camera_start_x = default_camera_position.x

	var numLevels = levels.size()
	var levelsPerRow = numLevels / ceil(numLevels / float(MAX_LEVELS_PER_ROW))
	var currentRow = 0
	var currentHBox
	
	for i in range(numLevels):
		if i >= currentRow * levelsPerRow:
			currentRow += 1
			currentHBox = HBoxContainer.new()
			currentHBox.alignment = HBoxContainer.ALIGNMENT_CENTER
			currentHBox.name = "Row" + str(currentRow)
			currentHBox.add_theme_constant_override("separation", 30)
			$Menu/Fases/CenterContainer/VBoxContainer.add_child(currentHBox)
			
		var levelButton = LEVEL_BUTTON.instantiate()
		levelButton.name = "Level" + str(i + 1)
		
		if i == numLevels - 1:
			levelButton.get_node("Label").text = '#'
		else:
			levelButton.get_node("Label").text = str(i + 1)
			
		levelButton.pressed.connect(transition_to_level.bind(i + 1))
		currentHBox.add_child(levelButton)
	
	animate_screen_transition()

# --- CORE LOOP ---
func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player) and not get_tree().paused:
		$Camera2D.global_position.x = player.global_position.x

# --- CONTINUOUS TRANSITION LOGIC ---
# Combined into a single, flawless sequence to prevent invisible physics glitches
func transition_into(callable: Callable):
	$Camera2D/TransitionScreen.show()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# 1. Fade to black
	tween.tween_property($Camera2D/TransitionScreen.material, "shader_parameter/progress", 1.0, TRANSITION_DURATION)
	
	# 2. Swap the level safely behind the black screen
	tween.tween_callback(callable)
	
	# 3. Fade back to clear
	tween.tween_property($Camera2D/TransitionScreen.material, "shader_parameter/progress", 0.0, TRANSITION_DURATION)
	
	# 4. Hide screen, unpause global tree, and FINALLY wake the level up
	tween.tween_callback($Camera2D/TransitionScreen.hide)
	tween.tween_callback(func(): get_tree().paused = false)
	tween.tween_callback(_unfreeze_level)

func _unfreeze_level():
	if level:
		# Wakes up the level physics and logic
		level.process_mode = Node.PROCESS_MODE_INHERIT
		
		# Triggers start animations only when the screen is actually visible
		if level.has_method("start_animations"):
			level.start_animations()

func animate_screen_transition():
	$Camera2D/TransitionScreen.show()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D/TransitionScreen.material, "shader_parameter/progress", 0.0, TRANSITION_DURATION)
	tween.tween_callback($Camera2D/TransitionScreen.hide)

func camera_transition_in():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(CAMERA_DEFAULT_ZOOM, CAMERA_DEFAULT_ZOOM), 0.5)
	var zoom_inverse = 1 / CAMERA_DEFAULT_ZOOM
	$Camera2D/TransitionScreen.scale = Vector2(zoom_inverse, zoom_inverse)
	$Camera2D/TransitionScreen.position = -$Camera2D/TransitionScreen.size * zoom_inverse / 2

func camera_transition_out():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(CAMERA_ZOOM_IN, CAMERA_ZOOM_IN), 0.5)
	var zoom_inverse = 1 / CAMERA_ZOOM_IN
	$Camera2D/TransitionScreen.scale = Vector2(zoom_inverse, zoom_inverse)
	$Camera2D/TransitionScreen.position = -$Camera2D/TransitionScreen.size * zoom_inverse / 2

func transition_camera_to_pause(paused: bool):
	var target_position = default_camera_position if paused else current_camera_position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D, "position", target_position, 0.5)

# --- LEVEL MANAGEMENT ---
func show_level_buttons():
	$Menu/Start.hide()
	$Menu/Fases.show()
	
func nextLevel():
	currentLevel += 1
	if currentLevel >= len(levels):
		camera_transition_out()
		transition_into(finish_game_and_return_to_menu)
		return
	
	transition_to_level(currentLevel + 1)

func finish_game_and_return_to_menu():
	if level:
		remove_child(level)
		level.queue_free()
		level = null
		
	if status:
		status.hide()
		
	$Camera2D.global_position = default_camera_position
	
	$Background.show()
	$Menu/Start.show()
	$Menu/Fases.hide()
	$Menu.show()
	
	if music_player.stream != MUSIC:
		music_player.stream = MUSIC
		music_player.play()
		
func transition_to_level(levelNum: int):
	$Background.hide()
	camera_transition_out()
	transition_into(playLevel.bind(levelNum))
	
func playLevel(levelNum):
	$Menu.hide()
	
	currentLevel = levelNum - 1
	if level:
		remove_child(level)
		level.queue_free()
		
	level = levels[currentLevel].instantiate()
	
	# CRITICAL: Freeze the level the millisecond it is created!
	level.process_mode = Node.PROCESS_MODE_DISABLED 
	
	level.player_death.connect(_on_player_death)
	level.level_completed.connect(nextLevel)
	add_child(level)
	
	player = level.get_node_or_null("Player")
	if player:
		player.fury_started.connect(_on_player_fury_started)
		player.fury_ended.connect(_on_player_fury_ended)
		player.jumps_changed.connect(status.update_jumps)
		status.update_jumps(player.max_jumps)
		
		$Camera2D.global_position = player.global_position
	
	if level and level.get("is_wide_level") != null and level.is_wide_level:
		$Background/TextureRect.hide()
	else:
		$Background/TextureRect.show()
	
	camera_start_x = $Camera2D.global_position.x
	camera_shifted = false

func retry_level():
	#$PauseMenu.hide()
	if currentLevel + 1 > len(levels):
		$Menu.hide()
		level.emit_signal('player_death')
	else:
		playLevel(currentLevel + 1)

# --- GAME OVER AND DEATH ---
func _on_player_death():
	numDeaths += 1
	
	if player:
		player.hide()
		
	show_game_over()

func _on_player_fury_started():
	music_player.stream = MAD_MUSIC
	music_player.play()
	
func _on_player_fury_ended():
	music_player.stream = MUSIC
	music_player.play()

func show_game_over():
	death_screen.show()
	get_tree().paused = true

func _on_death_screen_retry():
	death_screen.hide()
	# Game stays paused! transition_into will unpause it for us later.
	
	if music_player.stream != MUSIC:
		music_player.stream = MUSIC
		music_player.play()
		
	camera_transition_out()
	transition_into(retry_level)

func _on_death_screen_exit():
	death_screen.hide()
	# Game stays paused! transition_into will unpause it for us later.
	
	camera_transition_out()
	transition_into(return_to_menu)

# --- INPUT AND MENUS ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not $Menu.is_visible() and not death_screen.is_visible():
		if $PauseMenu.is_visible():
			resume_game()
			transition_camera_to_pause(false)
		else:
			$PauseMenu.show()
			camera_transition_in()
			$DeathCounter.hide()
			$collageScreen.hide()
			$collageScreen.process_mode = Node.PROCESS_MODE_DISABLED
			current_camera_position = $Camera2D.position
			transition_camera_to_pause(true)
			if level:
				level.hide()
				level.process_mode = Node.PROCESS_MODE_DISABLED

func _on_menu_start_game():
	transition_into(show_level_buttons)

func _on_pause_menu_resume_game() -> void:
	resume_game()

func resume_game():
	$PauseMenu.hide()
	
	if level:
		level.show()
		status.show()
		level.process_mode = Node.PROCESS_MODE_INHERIT

func _on_pause_menu_retry_level() -> void:
	camera_transition_out()
	transition_into(retry_level)

func _on_pause_menu_return_to_menu() -> void:
	transition_into(return_to_menu)

func return_to_menu():
	#$PauseMenu.hide()
	camera_transition_out()
	
	if level:
		remove_child(level)
		level.queue_free()
		level = null
		
	status.hide()
	$Camera2D.global_position = default_camera_position
	
	$Menu/Start.show()
	$Menu/Fases.hide()
	$Background.show()
	$Menu.show()
	
	if music_player.stream != MUSIC:
		music_player.stream = MUSIC
		music_player.play()
