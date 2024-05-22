extends Area2D

@export var sound: AudioStream
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if  body.is_in_group("player"):
		GameState._score_update(1)
		AudioManager._play(sound)
		queue_free()
