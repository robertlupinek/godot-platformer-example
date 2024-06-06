extends Area2D

@export var color: Color
@export var outline_color: Color
@export var y_gravity: float = 80
@export var x_speed_range: float = 50
@export var y_speed_range: float = -100
@export var x_scale_min: float = 0.3
@export var x_scale_max: float = 0.6

@export var y_scale_min: float = 0.2
@export var y_scale_max: float = 0.4

@export var alpha_reduce: float = 1

var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = randf_range(-x_speed_range,x_speed_range)
	velocity.y = randf_range(-50,y_speed_range)
	scale.x = randf_range(x_scale_min,x_scale_max)
	scale.y = randf_range(y_scale_min,y_scale_max)
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D2.play("outline")

func _physics_process(delta):
	velocity.y += y_gravity * delta
	modulate.a -= alpha_reduce * delta
	scale.x -= alpha_reduce * delta * 0.5
	scale.y -= alpha_reduce * delta * 0.5
	
	if scale.x < 0:
		scale.x = 0
	if scale.y < 0:
		scale.y = 0	
	# Rotation in radians
	rotation = velocity.angle()
	
	# Update position
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	
	$AnimatedSprite2D.modulate = color
	$AnimatedSprite2D2.modulate = outline_color
	
	if modulate.a <= 0:
		queue_free()
	
	
	
	
	


func _on_body_entered(body):
	queue_free() # Replace with function body.


func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	queue_free()
