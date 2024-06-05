extends Node2D

var velocity: float = 0;
var force: float = 0
var height: float = 0
var target_height: float = 0
# Can another collision occur timer
var can_collide_timer: Timer = Timer.new()
var can_collide_time: float = 0.1
# Multiplier * collider's  used to dampen impact on water
var collide_dampen: float = 0.005

func _ready():
	can_collide_timer.one_shot = true

func _initialize(x_position):
	# Reset height and target height to current position
	height = position.y
	target_height = position.y
	position.x = x_position
	velocity = 0

# Called when the node enters the scene tree for the first time.
func _water_update(spring_stiffness,dampening):
	# reset the height
	height = position.y
	# Spring current extension
	var h_diff = height - target_height
	var loss = -dampening * velocity
	
	# hooke's law ???
	force = - spring_stiffness * h_diff + loss
	velocity += force
	position.y += velocity


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if can_collide_timer.is_stopped():
		velocity += body.velocity.y * collide_dampen
		can_collide_timer.start(can_collide_time)
