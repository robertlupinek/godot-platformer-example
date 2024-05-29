extends HSlider

@export var bus_name: String
var bus_index: int
var sound: AudioStream = preload("res://sounds/soundfx/blip.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	if bus_name == "SFX":
		grab_focus()
	value_changed.connect(_on_value_changed)
	var bus_index = AudioServer.get_bus_index(bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
func _on_value_changed(value: float):
	AudioManager._play(sound)
	GameState.bus_volumes[bus_name] = value
	GameState._set_volumes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
