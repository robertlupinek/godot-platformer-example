extends Path2D

@export var speed = 200.0
@onready var path = $PathFollow2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path.progress += speed * delta


