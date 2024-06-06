extends Area2D

@export var color: Color
@export var outline_color: Color
@export var y_gravity: float = 80
@export var x_speed_min: float = -50
@export var x_speed_max: float = 50
@export var y_speed_min: float = -120
@export var y_speed_max: float = -80
@export var x_scale_min: float = 0.4
@export var x_scale_max: float = 0.7

@export var y_scale_min: float = 0.3
@export var y_scale_max: float = 0.5

@export var alpha_reduce: float = 1

var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	# We hide the particle and don't show it until the physics process.
	# That way if it is removed during a collision on the step it doesn't appear on the screen then 
	# suddenly vanish.  Just a little visual polish.	
	hide()
	# Set a random velocity
	velocity.x = randf_range(x_speed_min,x_speed_max)
	velocity.y = randf_range(y_speed_min,y_speed_max)
	scale.x = randf_range(x_scale_min,x_scale_max)
	scale.y = randf_range(y_scale_min,y_scale_max)
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D2.play("outline")

func _process(delta):
	# We change color here to ensure it is properly updated
	$AnimatedSprite2D.modulate = color
	$AnimatedSprite2D2.modulate = outline_color
	

	
	if scale.x < 0:
		scale.x = 0
	if scale.y < 0:
		scale.y = 0	
	# Rotation in radians
	rotation = velocity.angle()
	
	modulate.a -= alpha_reduce * delta
	if modulate.a <= 0:
		queue_free()
	scale.x -= alpha_reduce * delta * 0.5
	scale.y -= alpha_reduce * delta * 0.5

func _physics_process(delta):
	# We hide the particle and don't show it until the physics process.
	# That way if it is removed during a collision on the step it doesn't appear on the screen then 
	# suddenly vanish.  Just a little visual polish.
	show()
	# Update position
	velocity.y += y_gravity * delta
	position.x += velocity.x * delta
	position.y += velocity.y * delta

func _on_body_entered(body):
	queue_free()


func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	# Remove water drop from tree it collides with water springs
	if area.is_in_group("water_spring"):
		queue_free()
