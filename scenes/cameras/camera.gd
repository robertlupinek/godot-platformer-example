extends Camera2D

var shake_timer = Timer.new()
var shake_force: float = 1
var rand = RandomNumberGenerator.new()
var flash_alpha: float = 0
@export var snowing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup timers
	add_child(shake_timer)
	shake_timer.one_shot = true
	# Connect signals from GameFx 
	GameFx.connect("screen_flash",_flash)
	GameFx.connect("screen_shake",_shake)
	GameFx.connect("is_snowing",_snow)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# Set alpha for the flash rectangle.
	# Slowly reduce the alpha until it is no longer visible
	if flash_alpha > 0.05:
		flash_alpha = lerp(flash_alpha,0.0,0.1)	
		$FlashRect.color.a = flash_alpha
	else:
		flash_alpha = 0

	if not shake_timer.is_stopped():
		var offset_amount = 10 * shake_force
		var rotation_amount = 0.05 * shake_force
		offset = Vector2(rand.randf_range(-offset_amount,offset_amount),rand.randf_range(-offset_amount,offset_amount))
		rotation = rand.randf_range(-rotation_amount,rotation_amount)
	else:
		offset = Vector2(0,0)
		rotation = 0

		
func _shake(time: float = 0.5,force:float = 1):
	# Triggered via the GameFX scree_shake emitter.
	shake_force = force
	shake_timer.start(time)
			
func _snow(on: bool = true):
	# Triggered via the GameFX is_snowing emitter.
	$SnowParticles.emitting = on
		
func _flash(alpha: float = 1.0, color: Color = Color(255,255,255,1) ):
	# Triggered via the GameFX screen_flash emitter.
	flash_alpha = alpha
	$FlashRect.color = color
	$FlashRect.color.a = flash_alpha

	

