extends Button

@export var new_scene : String
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed",_goto_scene)


func _goto_scene():
	GameState._goto_scene(new_scene)
