extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Play
func _on_button_pressed():
	GameState._goto_scene("res://scenes/levels/1st_level.tscn")

# Quit
func _on_button_3_pressed():
	get_tree().quit()


func _on_button_2_pressed():
	GameState._goto_scene("res://scenes/menus/settings.tscn")
