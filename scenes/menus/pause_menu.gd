extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pause menu / exiting
	if Input.is_action_just_pressed("ui_escape"):
		if get_tree().paused:
			_on_unpause_pressed()
		else:
			get_tree().paused = true
			$VBoxContainer/Unpause.grab_focus()
			show()


func _on_unpause_pressed():
	hide()
	get_tree().paused = false


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
