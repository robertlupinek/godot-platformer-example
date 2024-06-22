extends CharacterBody2D

@export var speed = 50.0

@export var death_particle: PackedScene
@export var hp: float = 10
@export var jump_velocity = -400.0

var facing: int = 1

# Setup for taking damage
var hurt_timer: Timer  = Timer.new()
var hurt_time: float = 0.2
# Flash sprite or not
var flash: bool = false

# Dealing damage
var dmg: float = 1

# Animated Sprite
var animated_sprite: AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity: float = 500

func _ready():
	add_child(hurt_timer)
	hurt_timer.one_shot = true
	$AnimatedSprite2D.play("default")

func _physics_process(delta):

	# Add the gravity.
	velocity.y += gravity * delta
	# Start the flash animation
	if not hurt_timer.is_stopped():
		$FlashAnimation.play("flash")
	else:
		$AnimatedSprite2D.material.set_shader_parameter("active",false)
		$FlashAnimation.stop()
	move_and_slide()

func _flip():
	# Flip the facing direction
	facing = -facing
	# Flip sprite 
	$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
	
func _hurt(dmg_received: float):
	if hurt_timer.is_stopped():
		hurt_timer.start(hurt_time)
	# Screen shake!
	GameFx._screen_shake(0.2,0.25)
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
	var smoke = death_particle.instantiate()
	var world = get_tree().current_scene  
	smoke.position = global_position
	smoke.scale.x = -scale.x
	world.add_child(smoke)	
	get_parent().queue_free()

func _on_area_2d_damage_body_entered(body):
	if body.is_in_group("player"):
		body._hurt(dmg)
