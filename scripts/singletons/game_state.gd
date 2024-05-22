extends Node2D

var score: int = 0
var hp: int = 3
var max_hp: int = 3

# Signals
signal score_changed
signal player_hurt
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _score_update(points_gained: int):
	score += points_gained
	score_changed.emit()

	
	
