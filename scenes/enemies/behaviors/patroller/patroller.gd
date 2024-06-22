extends Node2D

# This scene must be added to an enemy_base scene to function.
# There are certain methods or functions only available in that scene's scripts.

# Base node of this enemy object
var base_body: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	base_body = get_node("../EnemyBase")
	
func _physics_process(delta):
	_patroller_behavior()
	global_position = base_body.global_position
	
func _flip_rays():
	# Flip the rays for collision detection
	$WallRayCast2D.target_position.x = -$WallRayCast2D.target_position.x
	$FloorRayCast2D.target_position.x = -$FloorRayCast2D.target_position.x
		

func _patroller_behavior():
	# Set velocity based on base body configuration
	base_body.velocity.x = base_body.speed * base_body.facing

	# Check for walls
	if $WallRayCast2D.is_colliding():
		var collider = $WallRayCast2D.get_collider()
		if collider:
			if not collider.is_in_group("player"):
				base_body._flip()
				_flip_rays()
		
	# Check for gaps
	if not $FloorRayCast2D.is_colliding():
		base_body._flip()
		_flip_rays()
