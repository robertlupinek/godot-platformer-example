extends RichTextLabel

var start_scale: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "Score: " + str(GameState.score)
	GameState.connect("score_changed",_grow_text)
	start_scale = scale
	_grow_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale.x = lerp(scale.x,start_scale.x,0.1)
	scale.y = lerp(scale.y,start_scale.y,0.1)
	text = "Score: " + str(GameState.score)
	
func _grow_text():
	scale.x = start_scale.x + 0.1
	scale.y = start_scale.y + 0.1
