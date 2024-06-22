extends Path2D

var root_parent: CharacterBody2D
# Position used to track and maintain position of Path2D globally
var start_position: Vector2
# Directions vector
var direction: Vector2
# Last position
var last_position: Vector2 = position

# Speed to move along the path
@export var speed: float = 50

# If not a looping path then just run the path again from current position
@export var continue_path: bool = true

signal path_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	root_parent = get_parent()
	start_position = root_parent.global_position
	last_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	$PathFollow2D.progress += speed * delta	
	# Reset current position to the start position.
	# The start_poition is set set on _ready and if continue_path is true
	global_position = start_position
	# Get direction
	_get_direction()
	# When path end
	if $PathFollow2D.progress_ratio == 1:
		emit_signal("path_complete")
		# Restart path from where path ends if continue_path is set
		if continue_path:
			_continue_path()
	
	root_parent.position = $PathFollow2D.global_position
	root_parent.rotation = $PathFollow2D.rotation
	
			

func _get_direction():
	pass

func _continue_path():
	# Keep following that path baby!  That is, if your path doesn't loop.  Cause just loop, right?
	if !$PathFollow2D.loop:
		# Reset the start position used to calculate origin to current global position.
		# The path2d_transform_parent.gd script uses this variable to it's parent along the PathFollow2d
		start_position = $PathFollow2D.global_position
		# Set the path to start again from the end
		$PathFollow2D.progress_ratio = 0
			
