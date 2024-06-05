extends AnimatedSprite2D

var choice_timer: Timer = Timer.new()
var focus: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	choice_timer.one_shot = true
	add_child(choice_timer)
	choice_timer.start(1)
	play("default")
	$ColorRect.color.a = 0
	$CanvasLayer/Control/HBoxContainer/Retry.grab_focus()
	$CanvasLayer/Control/HBoxContainer/Retry.hide()
	$CanvasLayer/Control/HBoxContainer/Quit.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Fade out the hud MAYBE
	for hud in get_tree().get_nodes_in_group("hud"):
		hud.queue_free()
	# Setup the buttons when the time is right
	if choice_timer.is_stopped():
		# Only set focus on the retry button once	
		if not focus:
			$CanvasLayer/Control/HBoxContainer/Retry.grab_focus()
		$CanvasLayer/Control/HBoxContainer/Retry.show()
		$CanvasLayer/Control/HBoxContainer/Quit.show()	
		focus = true	
	
	if $ColorRect.color.a < 1:
		$ColorRect.color.a += 1 * delta

func _on_animation_finished():
	if animation == "default":
		play("floats")

func _on_retry_pressed():
	_choice_made(GameState.scene)

func _on_quit_pressed():
	_choice_made("res://scenes/menus/main_menu.tscn")
	
func _choice_made(scene: String):
	get_tree().paused = false
	GameState._retry()
	GameState._goto_scene(scene)
