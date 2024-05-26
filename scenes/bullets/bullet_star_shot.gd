extends Area2D

@export var shot_sound: AudioStream
@export var hit_sound: AudioStream
@export var velocity: Vector2 = Vector2(0,0)
@export var particle: PackedScene
@export var dmg: float = 1

var remove_timer: Timer = Timer.new()

func _ready():
	AudioManager._play(shot_sound)
	$AnimatedSprite2D.play("default")
	var sparks = particle.instantiate()
	var world = get_tree().current_scene  
	sparks.position = position
	sparks.scale.x = scale.x
	world.add_child(sparks)	
	# Remove projectile from screen timer
	add_child(remove_timer)
	remove_timer.one_shot = true
	remove_timer.start(1)

	
func _physics_process(delta):
	position += velocity * delta
	if remove_timer.is_stopped():
		var world = get_tree().current_scene  
		var sparks = particle.instantiate()
		sparks.position = position
		sparks.scale.x = -scale.x
		world.add_child(sparks)	
		queue_free()
		

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if not body.is_in_group("player"):
		if body.is_in_group("enemies"):
			body._hurt(dmg)
		
		var sparks = particle.instantiate()
		var world = get_tree().current_scene  
		sparks.position = position
		sparks.scale.x = -scale.x
		world.add_child(sparks)	
		AudioManager._play(hit_sound)
		queue_free()
		
	

