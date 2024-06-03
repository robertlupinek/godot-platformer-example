extends Area2D

@export var dmg: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	# Collision processing for constant collision checks
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body._hurt(dmg)
