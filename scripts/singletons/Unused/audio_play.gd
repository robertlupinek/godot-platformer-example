extends Node

# WARNING!!!!
# No longer used but a good example of using an enum to reference a dictionary to make it referencing position in dictionary easy without tyrany of strings
# This method only allows 1 instance of a sound to play

enum Sounds {
	COLLECT,
	JUMP,
	LEVEL_UP
}

const SOUND_SOURCE : Dictionary = {
	Sounds.COLLECT : preload("res://Sounds/SoundFX/power_up.wav"),
	Sounds.JUMP : preload("res://Sounds/SoundFX/jump.wav"),
	Sounds.LEVEL_UP : preload("res://Sounds/SoundFX/level_up.wav")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _play(sound: Sounds):
	$Stream.stream = SOUND_SOURCE[sound]
	$Stream.play()
