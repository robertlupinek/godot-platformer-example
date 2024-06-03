extends Button

func _ready():
	focus_entered.connect(_focus_effect)
	
func _focus_effect():
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1.05,1.05), 0.05)
	tween.tween_property(self,"scale",Vector2(1,1), 0.05)
