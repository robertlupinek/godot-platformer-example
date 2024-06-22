extends Control

@export var click_sound: AudioStream
@export var first_scene: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_load_pressed():
	AudioManager._play(click_sound)
	GameState._load_game()
	GameState._goto_scene(GameState.scene)

func _on_new_game_pressed():
	AudioManager._play(click_sound)
	GameState.scene = first_scene
	GameState._save_game()
	GameState._goto_scene(GameState.scene)


func _on_settings_pressed():
	AudioManager._play(click_sound)
	GameState._goto_scene("res://scenes/menus/settings.tscn")


func _on_quit_pressed():
	AudioManager._play(click_sound)
	get_tree().quit()



