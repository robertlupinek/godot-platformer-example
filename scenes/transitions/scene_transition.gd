extends Node2D

# Exports
## Path to scene to load 
@export var new_scene_path: String = ""
@export var transition_name: String = ""
# Signals
signal transition_finished
signal transition_started

var test_timer: Timer = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():

	emit_signal("transition_started")
	# Create the tween for fading in
	var tween = create_tween()
	
	if transition_name == "fade_out":
		# Pause everything else
		get_tree().paused = true
		# Pause shaders
		Engine.time_scale = 0
		tween.tween_property($CanvasLayer/ColorRectFade,"modulate:a",1.0,0.5)
		tween.tween_callback(_transition_finished)
	elif transition_name == "fade_in":
		get_tree().paused = false		
		$CanvasLayer/ColorRectFade.modulate.a = 1
		tween.tween_property($CanvasLayer/ColorRectFade,"modulate:a",0,0.5)
		tween.tween_callback(_transition_finished)	
	else:
		print_debug("No transistion_name set...")
		get_tree().paused = false
		queue_free()
		
func _transition_finished():
	emit_signal("transition_finished")
	get_tree().paused = false
	# Unpause shaders
	Engine.time_scale = 1
	queue_free()
	if new_scene_path != "":
		print(new_scene_path)
		GameState._goto_scene(new_scene_path)
