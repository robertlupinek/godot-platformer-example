extends Control

var camera: Camera2D
@export var limit_left: int
@export var limit_right: int
@export var limit_top: int
@export var limit_bottom: int
@export var has_floor: bool = true
@export var has_ceiling: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set boundaries
	limit_left = int(position.x)
	limit_right = int(position.x) + int(size.x)
	limit_top = int(position.y)
	limit_bottom = int(position.y) + int(size.y)
	# Set the camera limits
	## Retrieve camera from root
	var parent = get_parent()
	camera = parent.get_node("Player/CameraInGame")
	camera.limit_left = limit_left
	camera.limit_right = limit_right
	camera.limit_top = limit_top
	camera.limit_bottom = limit_bottom
	# Set the collision boundaries
	$LeftCollider.global_position.x = position.x
	$RightCollider.global_position.x = position.x + size.x
	if has_floor:
		$BottomCollider.global_position.y = position.y + size.y
	else:
		$BottomCollider.queue_free()
	if has_ceiling:
		$TopCollider.global_position.y = position.y
	else:
		$TopCollider.queue_free()		
	

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
