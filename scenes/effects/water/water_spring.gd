extends Area2D

var velocity: float = 0;
var force: float = 0
var height: float = 0
var target_height: float = 0
# Can another collision occur timer
var can_collide_timer: Timer = Timer.new()
@export var can_collide_time: float = 0.1
# Multiplier * collider's  used to dampen impact on water
@export var collide_dampen: float = 0.05

var collision_shape: CollisionShape2D
var on_screen: bool = false

signal spring_collision

func _ready():
	add_child(can_collide_timer)
	can_collide_timer.one_shot = true
	collision_shape = $CollisionShape2D
	$VisibleOnScreenNotifier2D.rect.size = collision_shape.shape.size

func _initialize(x_position):
	# Reset height and target height to current position
	height = position.y
	target_height = position.y
	position.x = x_position
	velocity = 0

# Update water spring's bounce based on dampening, stiffness, force applied, and finally postion based on velocity.
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


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if can_collide_timer.is_stopped() and "velocity" in body:
		velocity += ( body.velocity.x + body.velocity.y ) * collide_dampen
		can_collide_timer.start(can_collide_time)
		emit_signal("spring_collision",self,body,velocity)


func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if can_collide_timer.is_stopped() and "velocity" in area:
		velocity += ( area.velocity.y + area.velocity.x ) * collide_dampen
		can_collide_timer.start(can_collide_time)
		emit_signal("spring_collision",self,area,velocity)


func _on_visible_on_screen_notifier_2d_screen_entered():
	on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	on_screen = false
