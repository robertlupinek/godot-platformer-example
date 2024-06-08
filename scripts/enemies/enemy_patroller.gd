extends CharacterBody2D


var speed = 50.0
var jump_velocity = -400.0

@export var hp: float = 10
var facing: int = 1
@export var particle: PackedScene

# Setup for taking damage
var hurt_timer: Timer  = Timer.new()
var hurt_time: float = 0.2
# Flash sprite or not
var flash: bool = false

# Dealing damage
var dmg: float = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.x = speed
	add_child(hurt_timer)
	hurt_timer.one_shot = true
	$AnimatedSprite2D.play("default")
	
func _physics_process(delta):

	# Add the gravity.
	velocity.y += gravity * delta
	# Check for walls
	if $WallRayCast2D.is_colliding():
		var collider = $WallRayCast2D.get_collider()
		if collider:
			if not collider.is_in_group("player"):
				_flip()
		
	# Check for gaps
	if not $FloorRayCast2D.is_colliding():
		_flip()

	# Start the flash animation
	if not hurt_timer.is_stopped():
		$FlashAnimation.play("flash")
	else:
		$AnimatedSprite2D.material.set_shader_parameter("active",false)
		$FlashAnimation.stop()			

	velocity.x = facing * speed
	$AnimatedSprite2D.play("default")

	# _collisions()
	move_and_slide()

func _collisions():
	# Loop through all collisions looking for a collision with player
	for i in get_slide_collision_count():
		var col: Node2D = get_slide_collision(i).get_collider()
		if col.is_in_group("player"):
			col._hurt(dmg)
	
func _flip():
	# Flip the facing direction
	facing = -facing
	# Flip sprite and raycast for walls
	$WallRayCast2D.target_position.x = -$WallRayCast2D.target_position.x
	$FloorRayCast2D.target_position.x = -$FloorRayCast2D.target_position.x
	$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
	velocity.x = -velocity.x
	
func _hurt(dmg_received: float):
	if hurt_timer.is_stopped():
		hurt_timer.start(hurt_time)
	# Screen shake!
	GameFx._screen_shake(0.02)
	# Play sound effects and do special effects
	# AudioManager._play(hurt_sound)
	# Effects
	# Reduce health
	if hp - dmg_received > 0:
		hp -= dmg_received	
	else:
		hp = 0
		_the_ending()
			
func _flash_sprite():
	if flash == true: 
		flash = false 
	else: 
		flash = true
	$AnimatedSprite2D.material.set_shader_parameter("active",flash)				
			
func _the_ending():
	var smoke = particle.instantiate()
	var world = get_tree().current_scene  
	smoke.position = position
	smoke.scale.x = -scale.x
	world.add_child(smoke)	
	queue_free()


func _on_area_2d_damage_body_entered(body):
	if body.is_in_group("player"):
		body._hurt(dmg)
