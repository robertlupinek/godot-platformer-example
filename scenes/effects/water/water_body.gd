extends Control
# Scene used for splash particles
@export var splash_particle: PackedScene
# Velocity required to spawn splash particles
@export var splash_velocity: float = 0.05
# How stiff the springs are when collided with.  Affects how much velocity impacts movement of water
@export var stiffness: float = 0.004
# How quickly to reduce the springs "wave"
@export var dampening: float = 0.03
# How much springs spread force to neighbors
var spread: float = 0.0003

# The spring array
var springs: Array = []
# How many times we update water neighbors
@export var passes: int = 10
# Distance between springs
@export var distance_between_springs: int = 16
# How many springs to add will be calculated based on distance between them and water size
var spring_count: int

# Color for the water
@export var water_color: Color
@export var water_outline_color: Color

# Top of the water
var target_height: float = global_position.y
# Bottom of the water
var bottom: float = target_height + size.y
# Polygon used to draw the water
var water_polygon: Polygon2D
var water_border: SmoothPath
@export var border_size: float = 0.2
# The springs used to make the waves
var water_spring: PackedScene = preload("res://scenes/effects/water/water_spring.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Reset the bottom of the water.  Otherwise it would be set to size in the packed scene vs instantiated transform.
	bottom = target_height + size.y
	
	# Resize and move collision shape to proper place based on size and position of this node
	$Area2D/CollisionShape2D.shape.size = size
	$Area2D.position += size / 2	
	
	# Make the rect for drawing where to put water disappear
	$ColorRect.hide()

	# Reference the polygon for drawing water
	water_polygon = $Polygon2DWater
	water_polygon.color = water_color
	water_border = $WaterBorder
	water_border.width = border_size
	
	# Get spring count based on size.x and distance between springs
	spring_count = round(size.x / distance_between_springs) + 1
	
	# Create springs for the water

	for i in range(spring_count):
		# Create new spring
		var new_spring = water_spring.instantiate()
		add_child(new_spring)
		# Connect new spring collisions with local function for effects
		new_spring.spring_collision.connect(_spring_collision)
		springs.append(new_spring)
		if i < spring_count -1:
			new_spring._initialize(distance_between_springs * i)
		else:
			new_spring._initialize(size.x)
		new_spring.collision_shape.shape.size.x = distance_between_springs


func _physics_process(delta):
	_process_springs()
	_new_border()				
	_draw_water_body()

func _process_springs():
	# Update all of the springs position based on
	#  dampening, stiffness, force applied, and finally postion based on velocity.
	for spring in springs:
		spring._water_update(stiffness,dampening)
	# Setup the arrays for checking neighboring springs height difference 
	# Used to calculate affect of bounce onn neighbor.
	var left_deltas: Array = []
	var right_deltas: Array = []
	# Set the values of left and right deltas to 0
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	# Process neighboring springs affects on each other based on height in bounce difference
	for j in range(passes):	
		for i in range (springs.size()):
			# If the spring is not the furthest "left" in the array then add the velocity of the left neighbor
			if 	i > 0:
				left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			# If the spring is not the furthest "right" in the array then add the velocity of the right neighbor
			if i < springs.size() -1:
				right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]	

func _new_border():
	# Draw a new border for the surface of the water.
	
	# Create new curve 2d
	var curve = Curve2D.new().duplicate()
	
	# Creates a new array to hold positions of surface pounts
	var surface_points: Array = []
	for spring in springs:
		surface_points.append(spring.position)
		
	for surface_point in surface_points:
		curve.add_point(surface_point)
		
	water_border.curve = curve
	water_border.smooth(true)
	water_border.queue_redraw()

func _draw_water_body():
	# Get the curve of the border
	var curve = water_border.curve
	# Make an array of points from the curve
	var water_polygon_points = Array(curve.get_baked_points())
		
	var first_index: int = 0
	var last_index:int = water_polygon_points.size()-1

	# Append the bottom right and left points to the polygon array
	water_polygon_points.append(Vector2(water_polygon_points[last_index].x,bottom))
	water_polygon_points.append(Vector2(water_polygon_points[first_index].x,bottom))
	water_polygon.set_polygon(PackedVector2Array(water_polygon_points))

	# Set the color of the water body
	water_polygon.material.set_shader_parameter("water_tint",water_color)
	water_border.color = water_outline_color
	

	
func _spring_collision(spring,body,velocity):
	# An object collided with a spring.
	# Add any special effects you want here.
	# Velocity is the velocity of the SPRING NOT the BODY !!!!
	# Spring's velocity and can collide timer are all set in the WaterSpring's _on_body_shape_entered method
	var abs_velocity = abs(velocity)
	if abs_velocity > splash_velocity and spring.on_screen:
		_splashes(4,body.position.x,spring.global_position.y-1,abs_velocity)
		# _splashes(4,body.position.x,body.global_position.y-1,abs_velocity)

			
func _splashes(count,x,y,velocity):
	var world = get_tree().current_scene 
	var splash: Area2D 
	for i in range(count):
		splash = splash_particle.instantiate()
		world.call_deferred("add_child",splash)
		splash.position = Vector2(x,y)
		splash.color = water_color
		splash.outline_color = water_outline_color
		splash.velocity.y -= velocity	
	# Set volume based on the velocity of object impacting
	var volume: float = -30 + velocity * 20
	# Set a random pitch to make the splashes seem less same same
	var pitch: float = 1 + randf_range(0,2)
	if randi_range(-10, 10) > 0:
		# Uncomment if you don't want the splash sound to start until the last is finished
		#if !$AudioStreamPlayerSplash1.playing:
			$AudioStreamPlayerSplash1.volume_db = volume
			$AudioStreamPlayerSplash1.pitch_scale = pitch
			$AudioStreamPlayerSplash1.play()
	else:
		# Uncomment if you don't want the splash sound to start until the last is finished
		#if !$AudioStreamPlayerSplash2.playing:
			$AudioStreamPlayerSplash2.volume_db = volume
			$AudioStreamPlayerSplash2.pitch_scale = pitch
			$AudioStreamPlayerSplash2.play()	
		
