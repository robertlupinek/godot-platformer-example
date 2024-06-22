extends Node2D

signal screen_flash
signal screen_shake
signal is_snowing
signal transition_finished

var transition: PackedScene = preload("res://scenes/transitions/scene_transition.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#####
# Signal functions
####
func _screen_shake(time: float,force: float ):
	emit_signal("screen_shake",time,force)
	
func _screen_flash(color: Color = Color(255,255,255,1) ):
	emit_signal("screen_flash")	
	
func _is_snowing(on: bool = true ):
	emit_signal("is_snowing")	
	
func _transition_scene(transition_name: String = "",scene_path: String = ""):
	var this_transition = transition.instantiate()
	this_transition.transition_finished.connect(_transition_finished)
	this_transition.new_scene_path = scene_path
	this_transition.transition_name = transition_name
	print(scene_path)
	var world = get_tree().current_scene
	world.add_child(this_transition)
	
func _transition_finished():
	emit_signal("transition_finished")
	print("Transition finished")
	
	
	
	
