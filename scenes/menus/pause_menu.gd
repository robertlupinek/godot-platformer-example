extends CanvasLayer

var old_focus: Control

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
			# For pausing shaders
			Engine.time_scale = 0
			# Get the current button or object that has focus.  We need to give it focus
			# back when we unpause else we break non-mouse driven input.
			old_focus = get_viewport().gui_get_focus_owner()
			# Give focus to the unpause button 
			$PauseMenu/VBoxContainer/Unpause.grab_focus()
			
			show()


func _on_unpause_pressed():
	hide()
	# Give focus back to the OG node that had focus if it exists
	if old_focus:
		old_focus.grab_focus()
	# Unause everything in the tree according to it's process mode
	get_tree().paused = false
	# Unpause shaders
	Engine.time_scale = 1


func _on_quit_pressed():
	# Unpause everything in the tree according to it's process mod	
	get_tree().paused = false
	# Return to the main menu
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
