extends Node2D

const SAVE_PATH: String = "res://savegame.bin"
const SAVE_PASS: String = "bloopyblooperton"

var score: int = 0
var hp: int = 3
var max_hp: int = 3

var player_state: Dictionary = {
	"score" : score,
	"hp" : hp,
	"max_hp" : max_hp
}

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

var settings: Dictionary = {
	"bus_volumes" : bus_volumes,
	"full_screen" : full_screen,
}


var save_game_data: Dictionary = {
	"scene" : scene,
	"settings" : settings,
	"player_state" : player_state
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_volumes()
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _goto_scene(new_scene: String):
	scene = new_scene
	get_tree().change_scene_to_file(new_scene)
	# Don't think we need to set volumes... 
	# I thought we might when I was not setting the volumes right.  I think I was not changing the index I looked up and only setting index 0 = "Master".
	# _set_volumes()

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

func _save_game():
	var file = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	var json_string = JSON.stringify(save_game_data)
	file.store_line(json_string)
	print(json_string)

func _load_game():
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	if not file:
		return
	if file == null:
		return
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line)
			if current_line:
				print(current_line)
	
