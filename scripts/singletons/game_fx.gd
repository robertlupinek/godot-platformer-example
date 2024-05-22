extends Node2D

signal screen_flash
signal screen_shake

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
#####
# Signal functions
####
func _screen_shake(timer: float ):
	emit_signal("screen_shake")
	
func _screen_flash(color: Color = Color(255,255,255,1) ):
	emit_signal("screen_flash")	
