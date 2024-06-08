extends AnimatedSprite2D

@export var character : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# If moving - Put any animation selection logic in this section for animations at change based on if the character moving horizontally or not.
	if character.direction_x and not character.swimming:
		## If moving while on floor
		if character.is_on_floor():
			play("run")
		if character.swimming:
			play("swim")
	# If not moving		
	elif not character.swimming:
		if character.is_on_floor():
			play("idle")	
		if character.swimming:
			play("swim")

	# Play animation faster if dashing
	if not character.dash_timer.is_stopped() and not character.swimming:
		play("jump")
		speed_scale = 10
	elif not character.swimming:
		speed_scale = 1

	## If moving and midair - midair sprite selection doesn't rely on character horizontal movement.
	if !character.is_on_floor() and !character.is_on_wall() and not character.swimming:
		if character.velocity.y < 0:
			if not animation == "flip":
				play("jump")
		else:
			if not animation == "flip":
				play("jump_down")
			
	## Swimming
	if character.swimming:
		if character.direction_x:
			play("swim")
		else:
			play("swim_idle")
		

func _on_animation_looped():
	if animation == "flip":
		play("jump")
