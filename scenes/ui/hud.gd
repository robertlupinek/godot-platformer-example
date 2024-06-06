extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	show()

func _process(delta):
	$FPS.text = str(Engine.get_frames_per_second())
