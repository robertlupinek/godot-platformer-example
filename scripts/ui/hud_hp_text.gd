extends RichTextLabel

var font = Font
var start_scale: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	font = get_theme_font("normal_font")
	text = str(GameState.hp) + "/" + str(GameState.max_hp)
	start_scale = scale
	GameState.connect("player_hurt",_grow_text)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(GameState.hp) + "/" + str(GameState.max_hp)
	scale.x = lerp(scale.x,start_scale.x,0.1)
	scale.y = lerp(scale.y,start_scale.y,0.1)

func _draw():
	# draw_string(font,Vector2(70,10),"FART!!!!!!",0,-1,16,)
	pass
	
func _grow_text():
	scale.x = start_scale.x + 0.1
	scale.y = start_scale.y + 0.1	
