extends Node2D

var score: int = 0
var hp: int = 3
var max_hp: int = 3

# Signals
signal score_changed
signal player_hurt

var bus_volumes: Dictionary = {
	"Master" : 1,
	"Music" : 0.77,	
	"SFX" : 0.77
}

var scene: String

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
		
	

	
	
