extends Button

@export var new_scene : String = ""
@export var grab_focus_on : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if grab_focus_on:
		grab_focus()
	connect("pressed",_goto_scene)
	focus_entered.connect(_focus_effect)
	
func _focus_effect():
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1.05,1.05), 0.05)
	tween.tween_property(self,"scale",Vector2(1,1), 0.05)

func _goto_scene():
	if new_scene != "":
		GameState._goto_scene(new_scene)
	else:
		GameState._goto_scene(GameState.scene)
