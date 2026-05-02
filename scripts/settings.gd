extends Control

# Componentes
@onready var musica_off_button = $Fundo/VBoxContainer/HBoxContainer/Control/MusicaOff
@onready var volume_off_button = $Fundo/VBoxContainer/HBoxContainer2/Control/VolumeOff
@onready var volume_musica_slider = $Fundo/VBoxContainer/HBoxContainer/Musica
@onready var volume_geral_slider = $Fundo/VBoxContainer/HBoxContainer2/Volume
@onready var btn_voltar = $Fundo/Control/back

# Variaveis
var bus_master_idx = AudioServer.get_bus_index("Master")
var bus_music_idx = AudioServer.get_bus_index("Music")
const CONFIG_FILE_PATH = "user://game_settings.cfg"
var config = ConfigFile.new()

# Funcoes Principais
func _ready():
	load_settings()

	volume_geral_slider.value_changed.connect(_on_volume_geral_slider_value_changed)
	volume_musica_slider.value_changed.connect(_on_volume_musica_slider_value_changed)
	btn_voltar.pressed.connect(_on_btn_voltar_pressed)

# Sinais de Audio
func _on_volume_geral_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_master_idx, linear_to_db(value))
	if volume_off_button.button_pressed:
		volume_off_button.button_pressed = false
		_on_volume_off_toggled(false)

func _on_volume_musica_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_music_idx, linear_to_db(value))
	if musica_off_button.button_pressed:
		musica_off_button.button_pressed = false
		_on_musica_off_toggled(false)

# Sistema de Save
func save_settings():
	config.load(CONFIG_FILE_PATH)

	config.set_value("audio", "master_volume", volume_geral_slider.value)
	config.set_value("audio", "music_volume", volume_musica_slider.value)
	config.set_value("audio", "master_mute", volume_off_button.button_pressed)
	config.set_value("audio", "music_mute", musica_off_button.button_pressed)

	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		printerr("Erro ao salvar configurações: ", error)

func load_settings():
	var error = config.load(CONFIG_FILE_PATH)
	
	if error == OK:
		var master_vol = config.get_value("audio", "master_volume", 1.0)
		var music_vol = config.get_value("audio", "music_volume", 1.0)
		var master_mute = config.get_value("audio", "master_mute", false)
		var music_mute = config.get_value("audio", "music_mute", false)

		volume_geral_slider.set_value_no_signal(master_vol)
		volume_musica_slider.set_value_no_signal(music_vol)
		volume_off_button.set_pressed_no_signal(master_mute)
		musica_off_button.set_pressed_no_signal(music_mute)

		AudioServer.set_bus_volume_db(bus_master_idx, linear_to_db(master_vol))
		AudioServer.set_bus_volume_db(bus_music_idx, linear_to_db(music_vol))
		AudioServer.set_bus_mute(bus_master_idx, master_mute)
		AudioServer.set_bus_mute(bus_music_idx, music_mute)
	else:
		volume_geral_slider.set_value_no_signal(1.0)
		volume_musica_slider.set_value_no_signal(1.0)
		volume_off_button.set_pressed_no_signal(false)
		musica_off_button.set_pressed_no_signal(false)
		
		AudioServer.set_bus_volume_db(bus_master_idx, linear_to_db(1.0))
		AudioServer.set_bus_volume_db(bus_music_idx, linear_to_db(1.0))
		AudioServer.set_bus_mute(bus_master_idx, false)
		AudioServer.set_bus_mute(bus_music_idx, false)

# Sinais de Interface
func _on_btn_voltar_pressed():
	save_settings()
	hide()
	if get_parent().has_method("show_menu"):
		get_parent().show_menu()

func _on_musica_off_toggled(toggled_on):
	AudioServer.set_bus_mute(bus_music_idx, toggled_on)

func _on_volume_off_toggled(toggled_on):
	AudioServer.set_bus_mute(bus_master_idx, toggled_on)
