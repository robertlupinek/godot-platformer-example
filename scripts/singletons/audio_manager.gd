extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _play(stream: AudioStream):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = stream
	audio_player.bus = "SFX"
	audio_player.finished.connect(_remove_audio_player.bind(audio_player))
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(audio_player)
	audio_player.play()
	return audio_player.get_instance_id()

func _remove_audio_player(audio_player: AudioStreamPlayer):
	audio_player.queue_free()
