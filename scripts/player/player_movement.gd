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

# Sounds
@export var jump_sound = AudioStream
@export var hurt_sound = AudioStream
@export var dash_sound = AudioStream

# Current Speed
var speed: float = ground_speed
# Current horizontal friction.  Changes based on state of playing 
var friction : float = ground_speed
var direction_x : float
var facing : float = 1
var is_player : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
# Configure jumping
var coyote_timer: Timer = Timer.new()
@export var coyote_time : float = 0.1
var landed : bool = false
# Double jump and so on :)
@export var extra_jumps : int = 1
var current_extra_jumps = extra_jumps

# Set max fall speed
@export var max_velocity_y: float = 250

# Setup for taking damage
var hurt_timer: Timer  = Timer.new()
var hurt_time: float = 1 
var flash: bool = false

# Dashing
var dash_timer: Timer  = Timer.new()
@export var dash_time: float = 1 
@export var dash_speed: float = 200
var dash_line_timer: Timer  = Timer.new()
var dash_line_time: float = 0.1

# Bullets
var bullet_star_shot: PackedScene = preload("res://scenes/bullets/bullet_star_shot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
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

func _process(delta):
	
	# Start the flash animation
	if not hurt_timer.is_stopped():
		
		$FlashAnimation.play("flash")
	else:
		$AnimatedSprite2D.material.set_shader_parameter("active",false)
		$FlashAnimation.stop()

func _physics_process(delta):
	
	# Player State
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
		if landed == false:
			var asdf = 1
		landed = true
		## Start the coyote time to indicate you can now jump
		coyote_timer.start(coyote_time)
		
	## On wall
	if is_on_wall():
		## Allow wall jump
		coyote_timer.start(coyote_time)
		## Reset extra jumps count
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
	
	if direction_x:
		velocity.x += direction_x * speed * delta
	## Applying horizontal friction always redcucing speed vs when not moving.  Uncomment `else` only apply friction when not moving.
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	## Keep x velocity from going over max velocity
	if abs(velocity.x) > max_velocity:
		velocity.x = max_velocity * sign(velocity.x)

	# Handle jumping.  
	
	## We use a "coyote" timer to determine when you can jump vs if on ground.
	if Input.is_action_just_pressed("ui_accept") and ( not coyote_timer.is_stopped() or current_extra_jumps > 0 ):
		## Only count the jump as a "double" or "tripple" or more jump IF the coyote timer has stopped indicating you are not on the ground.
		if coyote_timer.is_stopped():
			current_extra_jumps -= 1
			$AnimatedSprite2D.play("flip")
		velocity.y = jump_velocity
		# Play the jump sound
		AudioManager._play(jump_sound)

		## Wall jump off the wall a bit.  Make sure we are also not on the floor.  This would be weird trying to jump over walls and just bouncing back.
		if is_on_wall() and not is_on_floor():
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
			position.y +=1
			
	# Dash
	if Input.is_action_just_pressed("ui_dash"):
		if dash_timer.is_stopped():
			velocity.y = 0
			
			dash_timer.start(dash_time)
			dash_line_timer.start(dash_line_time)
			# Flip the facing directio_xn for the player if on the wall 
			# so we can dash OFF the wall vs INTO it
			if is_on_wall() and not is_on_floor():
				facing = -facing
			# Set the movement speed on the x axis based on the directio_xn the player is facing ( -1 = left, 1 = right )
			velocity.x = facing * dash_speed
			AudioManager._play(dash_sound)
			$Line2D.clear_points()
			$Line2D.global_position = Vector2(0,0)
			$Line2D.add_point(global_position)
			
	if not dash_line_timer.is_stopped():
		$Line2D.global_position = Vector2(0,0)
		$Line2D.add_point(global_position)
		$Line2D.visible = true
	else:
		if $Line2D.get_point_count() > 0:
			$Line2D.remove_point(0)
			
	# Enforce a max velociy
	if velocity.y > max_velocity_y:
		velocity.y	= max_velocity_y
		
	# Shooting
	if Input.is_action_just_pressed("ui_attack_1"):
		_shoot(bullet_star_shot)
		
	_set_animation()
	
	# Handle physics
	move_and_slide()
	
	# Check for moving outside of play boundaries
	if position.y >= 1524:
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
	GameState.hp = GameState.max_hp
	GameState.score = 0
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

