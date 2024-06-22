extends Node

@export var set_scene_as_checkpoint: bool = false

# This script should be attached to the root node of a level.  MAYBE.
# Not sure if I want this or not :P

# Called when the node enters the scene tree for the first time.
func _ready():
	if set_scene_as_checkpoint:
		GameState.scene = scene_file_path
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
