extends HSlider

@export var bus_name: String
@export var bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready():
	value_changed.connect(_on_value_changed)
	var bus_index = AudioServer.get_bus_index(bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
func _on_value_changed(value: float):
	GameState.bus_volumes[bus_name] = value
	GameState._set_volumes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
