extends Node2D

const GAME_SAVE_PATH: String = "user://savegame.sav"
const SETTINGS_SAVE_PATH: String = "user://settings.sav"
const SAVE_PASS: String = "bloopyblooperton"

var score: int = 0

var max_hp: float = 3
var hp: float = max_hp

# Signals
signal score_changed
signal player_hurt

# Game Settings


var full_screen: bool = false : set = _set_full_screen

var bus_volumes: Dictionary = {
	"Master" : 1,
	"Music" : 0.77,	
	"SFX" : 0.77
}
var scene: String

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_settings()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _goto_scene(new_scene: String):
	scene = new_scene
	get_tree().change_scene_to_file(new_scene)

func _score_update(points_gained: int):
	score += points_gained
	score_changed.emit()
	
func _set_volumes():
	for bus_name in bus_volumes:
		var volume = bus_volumes[bus_name]
		var bus_index = AudioServer.get_bus_index(bus_name)
		print("bus: " + bus_name + " vol: " + str(volume) )
		AudioServer.set_bus_volume_db(bus_index,linear_to_db(volume))
		
func _set_full_screen(set_value: bool):
	if set_value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)	
	full_screen = set_value

func _save_settings():
	var file = FileAccess.open(SETTINGS_SAVE_PATH,FileAccess.WRITE)
	file.store_var(bus_volumes)
	file.store_var(full_screen)

func _load_settings():
	
	if FileAccess.file_exists(SETTINGS_SAVE_PATH) == true:
		var file = FileAccess.open(SETTINGS_SAVE_PATH,FileAccess.READ)
		bus_volumes = file.get_var()
		full_screen = file.get_var()
	_set_full_screen(full_screen)
	_set_volumes()


func _save_game():
	var file = FileAccess.open(GAME_SAVE_PATH,FileAccess.WRITE)
	file.store_var(scene)
	file.store_var(score)
	file.store_var(hp)
	file.store_var(max_hp)	

func _load_game():
	
	if FileAccess.file_exists(GAME_SAVE_PATH) == true:
		var file = FileAccess.open(GAME_SAVE_PATH,FileAccess.READ)
		scene = file.get_var()
		score = file.get_var()
		hp = file.get_var()
		max_hp = file.get_var()
		
	_set_full_screen(full_screen)
	_set_volumes()
	
func _retry():
	hp = max_hp

