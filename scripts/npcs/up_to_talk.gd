extends Area2D

@export var dialog: DialogueResource = preload("res://dialog/first_chat.dialogue")
const BALLOON: PackedScene = preload("res://dialog/balloons/dialog_balloon.tscn")
var dialog_started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if Input.is_action_just_pressed("ui_up"):
				if not dialog_started:
					dialog_started = true
					var balloon: CanvasLayer = BALLOON.instantiate()
					get_tree().current_scene.add_child(balloon)
					balloon.start(dialog,"first_chat")
					balloon.tree_exiting.connect(_dialog_ends)
					_pause_players(true)

func _pause_players(pause: bool = true):
	# Get all nodes in the player group
	var players = get_tree().get_nodes_in_group("player")
	# Freeze or unfreeze players based on pause parameter
	# To keep nodes within player unfrozen set the process mode to PAUSABLE 
	for player in players:
		if pause == true:
			player.process_mode = PROCESS_MODE_DISABLED
		else:
			player.process_mode = PROCESS_MODE_INHERIT

				
func _dialog_ends():
	print("Dialog ended")
	dialog_started = false
	_pause_players(false)
