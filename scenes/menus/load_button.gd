extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	if FileAccess.file_exists(GameState.GAME_SAVE_PATH) == true:
		grab_focus()
		show()
	focus_entered.connect(_focus_effect)
	
func _focus_effect():
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1.05,1.05), 0.05)
	tween.tween_property(self,"scale",Vector2(1,1), 0.05)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
