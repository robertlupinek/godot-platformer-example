extends CharacterBody2D


# Signals
signal hurt

# Exports
@export var ground_speed : float = 1000.0
@export var air_speed : float = 500.0
@export var jump_velocity : float = -250.0
@export var max_velocity : float = 150.0
@export var ground_friction : float = 24.0
@export var air_friction : float = 7.0
@export var wall_jump_velocity_x = 350
@export var swim_friction: float = 2.0
@export var swim_gravity: float = 100 
@export var swim_speed: float = 100 
@export var swim_jump_velocity: float = -100
@export var max_swim_velocity_y: float = 80
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity : float = 600 # ProjectSettings.get_setting("physics/2d/default_gravity")


# Current Speed
var speed: float = ground_speed
# Current horizontal friction.  Changes based on state of playing 
var friction : float = ground_speed
var direction_x : float
var facing : float = 1
var is_player : bool = false

# Configure swimming
var swimming: bool = false

# Configure jumping
var coyote_timer: Timer = Timer.new()
@export var coyote_time : float = 0.1
var landed : bool = false
# Double jump and so on :)
@export var extra_jumps : int = 1
var current_extra_jumps = extra_jumps
# Time that represents jump pressed
var jump_pressed_timer: Timer = Timer.new()
@export var jump_pressed_time: float = 0.1
# Set max fall speed
@export var max_velocity_y: float = 250

# Setup for taking damage
var hurt_timer: Timer  = Timer.new()
var hurt_time: float = 1 
var flash: bool = false

# Dashing
## How long to dash
var dash_timer: Timer  = Timer.new()
@export var dash_time: float = 1 
## How long before you can dash again
var dash_delay_timer: Timer  = Timer.new()
@export var dash_delay_time: float = 1.5
## Velocity to dash during dash_time
@export var dash_speed: float = 200
var dash_line_timer: Timer  = Timer.new()
var dash_line_time: float = 0.1

# Bullets
var bullet_star_shot: PackedScene = preload("res://scenes/bullets/bullet_star_shot.tscn")

# Sounds
@export var jump_sound = AudioStream
@export var hurt_sound = AudioStream
@export var dash_sound = AudioStream

# Death scene
var death_scene: PackedScene = preload("res://scenes/player/player_dies.tscn")

# Camera
var camera: Camera2D
# World boundary.  We don't slide on these guys, and we need to be aware of it for other collisions.
@export var world_boundary_layer: int = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the camera variable
	camera = $CameraInGame
	# Add all of the timers :)
	## jump pressed time
	add_child(jump_pressed_timer)
	jump_pressed_timer.one_shot = true
	## Coyote jump time
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	coyote_timer.start(coyote_time)	
	# Hurt timer
	add_child(hurt_timer)
	hurt_timer.one_shot = true
	# Dash timer
	add_child(dash_timer)
	dash_timer.one_shot = true	
	# Dash line timer
	add_child(dash_line_timer)
	dash_line_timer.one_shot = true		
	# Dash delay timer
	add_child(dash_delay_timer)
	dash_delay_timer.one_shot = true			

func _process(delta):
	
	# Start the flash animation
	if not hurt_timer.is_stopped():
		
		$FlashAnimation.play("flash")
	else:
		$AnimatedSprite2D.material.set_shader_parameter("active",false)
		$FlashAnimation.stop()

func _physics_process(delta):
	
	# Player State
	## Preset swimming to false
	var old_swimming = swimming
	swimming = false
	## Check if you are in a liquid / water
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("water"):
			var area_top = area.collision_shape.global_position.y - area.collision_shape.shape.size.y / 2
			var player_top = $Area2D/CollisionShape2D.global_position.y - $Area2D/CollisionShape2D.shape.size.y / 2
			if area_top < player_top:
				swimming = true
				## Reset extra jumps count
				current_extra_jumps = extra_jumps

	if old_swimming and !swimming:
		if Input.is_action_pressed("ui_accept"):
			velocity.y = jump_velocity
		coyote_timer.stop()
	
	if swimming:
		friction = swim_friction
		velocity.y += swim_gravity * delta
		coyote_timer.start(10)
		speed = swim_speed
	else:
		## Handle all changes required for when landing on the floor or being midair.
		if not is_on_floor():
			## Midair
			## Add the gravity.
			velocity.y += gravity * delta
			speed = air_speed
			friction = air_friction
			landed = false
		else:
			## On floor
			speed = ground_speed
			friction = ground_friction
			## Reset extra jumps count
			current_extra_jumps = extra_jumps
			## Do thing when you just landed for the first time.
			#if landed == false:
			#	var asdf = 1
			landed = true
			## Start the coyote time to indicate you can now jump
			coyote_timer.start(coyote_time)
			
		## On wall
		if is_on_wall():
			### Super complicated way to check if you are colliding with a world boundary
			### or a "normal" wall based on the collision layer of the last collision from slide and collide.
			var can_wall_slide: bool = true
			var collider = get_last_slide_collision().get_collider()
			### Tiles don't have a way to check if they have a collision layer :(
			### Good news is tiles aren't world collision boundaries, so they can be excluded from the check.
			if collider.get_class() == "StaticBody2D":
				### get_collision_layer_values returns true, so we just set the inverse ( true = false etc ) result to can_wall_slide using the !
				can_wall_slide = !collider.get_collision_layer_value(world_boundary_layer)
			### So you are sliding on a normal no world boundary wall.  Why must we check so many things :)
			if can_wall_slide:
				$AnimatedSprite2D.play("wall")
				#### Allow wall jump
				coyote_timer.start(coyote_time)
				#### Reset extra jumps count
				current_extra_jumps = extra_jumps
				if direction_x != 0:
					if velocity.y > 30:
						velocity.y = 30
		
	# Horizontal movement
	## Get the input direction_x and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	direction_x = Input.get_axis("ui_left", "ui_right")
	## Get the direction_x the player is facing
	if direction_x != 0:
		facing = sign(direction_x)
	
	# Perform normal movement if not dashing
	if dash_timer.is_stopped():
		if direction_x:
			velocity.x += direction_x * speed * delta
		## Applying horizontal friction always redcucing speed vs when not moving.  Uncomment `else` only apply friction when not moving.
		else:
			velocity.x = move_toward(velocity.x, 0, friction)
		# Normal collisions
		set_collision_layer_value(2,true)
		


	# Handle jumping.  
	
	## We use a "coyote" timer to determine when you can jump vs if on ground.
	if Input.is_action_just_pressed("ui_accept"):
		jump_pressed_timer.start(jump_pressed_time)
	
	if not jump_pressed_timer.is_stopped() and ( not coyote_timer.is_stopped() or current_extra_jumps > 0 ):
		## Only count the jump as a "double" or "tripple" or more jump IF the coyote timer has stopped indicating you are not on the ground.
		if coyote_timer.is_stopped():
			current_extra_jumps -= 1
			$AnimatedSprite2D.play("flip")
		if not swimming:
			velocity.y = jump_velocity
			# Play the jump sound
			AudioManager._play(jump_sound)			
		else:
			velocity.y += swim_jump_velocity


		# Stop the jump pressed timer
		jump_pressed_timer.stop()

		## Wall jump off the wall a bit.  Make sure we are also not on the floor.  This would be weird trying to jump over walls and just bouncing back.
		if is_on_wall() and not is_on_floor() and not swimming:
			velocity.x = wall_jump_velocity_x * -direction_x  
		## Stop the coyote timer
		coyote_timer.stop()
	## Release jump button
	if Input.is_action_just_released("ui_accept"):
		if velocity.y < 0:
			velocity.y = velocity.y * 0.4

	# Jump down
	if Input.is_action_just_pressed("ui_down"):
		if is_on_floor():
			position.y += 1
			
	# Dash
	if Input.is_action_just_pressed("ui_dash"):
		# Only dash if the dash delay time is stopped
		if dash_delay_timer.is_stopped():
			# Disable ability for things to collide with player
			set_collision_layer_value(2,false)
			velocity.y = 0
			# Start drawing the line 
			$Line2DDash.clear_points()
			$Line2DDash.global_position = Vector2(0,0)
			$Line2DDash.add_point(global_position)			
			
			dash_delay_timer.start(dash_delay_time)
			dash_timer.start(dash_time)
			dash_line_timer.start(dash_line_time)
			# Flip the facing directio_xn for the player if on the wall 
			# so we can dash OFF the wall vs INTO it
			if is_on_wall() and not is_on_floor():
				facing = -facing
			# Set new velocity
			velocity.x = dash_speed * facing
			AudioManager._play(dash_sound)

	# Draw the dash line 2d if dashing, else reduce it until it disappears
	if not dash_line_timer.is_stopped():
		$Line2DDash.global_position = Vector2(0,0)
		$Line2DDash.add_point(global_position)
		$Line2DDash.visible = true
	else:
		if $Line2DDash.get_point_count() > 0:
			$Line2DDash.remove_point(0)
			

		
	# Shooting
	if Input.is_action_just_pressed("ui_attack_1"):
		_shoot(bullet_star_shot)
		
	# Test stuff
	if Input.is_action_just_pressed("ui_test"):
		GameFx._transition_scene("fade_out","res://scenes/menus/main_menu.tscn")
		
	# Set animation and scaling and any animation related fun stuff
	_set_animation()
	
	# Handle physics
	
	### Enforce a max velocity.y
	if not swimming:
		if velocity.y > max_velocity_y:
			velocity.y	= max_velocity_y
	else:
		if velocity.y > max_swim_velocity_y:
				velocity.y	-= 600 * delta

	
	### Keep x velocity from going over max velocity if not dashing
	if dash_timer.is_stopped():
		if abs(velocity.x) > max_velocity:
			velocity.x = max_velocity * sign(velocity.x)
		
	move_and_slide()
	
	# Set a fall max - can be removed maybe?
	if position.y >= $CameraInGame.limit_bottom:
		_the_ending()
		
	# Debug info
	
func _set_animation():
	$AnimatedSprite2D.scale.x = facing

func _shoot(bullet: PackedScene):
	var shot = bullet.instantiate()
	var world = get_tree().current_scene  
	
	if is_on_wall() and not is_on_floor():
		shot.scale.x = -facing
	else:
		shot.scale.x = facing
	shot.velocity = Vector2(200*shot.scale.x,0)
	shot.position = Vector2(position.x + 8 * shot.scale.x,position.y)
	world.add_child(shot)
	AudioManager._play(dash_sound)


func _hurt(dmg_received: float):
	if hurt_timer.is_stopped():
		hurt_timer.start(hurt_time)
		# Emit the signal in game state for injured player
		GameState.emit_signal("player_hurt")
		# Screen shake!
		GameFx._screen_shake(0.02)
		# Play sound effects and do special effects
		AudioManager._play(hurt_sound)
		velocity.y -= 50
		velocity.x = -facing * 150
		# Effects
		
		# Reduce health
		if GameState.hp - dmg_received > 0:
			GameState.hp -= dmg_received	
		else:
			GameState.hp = 0
			_the_ending()
			
func _flash_sprite():
	if flash == true: 
		flash = false 
	else: 
		flash = true
	$AnimatedSprite2D.material.set_shader_parameter("active",flash)

func _the_ending():
	var death = death_scene.instantiate()
	var world = get_tree().current_scene
	world.add_child(death)
	# Hide vs dequeueing - we need the camera :)
	hide()
	death.position = position
	death.scale.x = facing
	
func _get_collision_shape(area: Area2D) -> CollisionShape2D:
	for child in area.get_children():
		if child is CollisionShape2D:
			return child
	return null

