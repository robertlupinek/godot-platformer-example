extends Control

@export var stiffness: float = 0.004
@export var dampening: float = 0.03
# How much waves spread force to neighborsd
var spread: float = 0.0003

# The spring array
var springs: Array = []
# How many times we update water neighbors
@export var passes: int = 10
# Distance between springs
@export var distance_between_springs: int = 16
# How many springs to add will be calculated based on distance between them and water size
var spring_count: int

@export var water_color: Color

var target_height: float = global_position.y
var bottom: float = target_height + size.y

var water_polygon: Polygon2D

var water_spring: PackedScene = preload("res://scenes/effects/water/water_spring.tscn")

var water_border: SmoothPath
@export var border_size: float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Reset the bottom of the water.  Otherwise it would be set to size in the packed scene vs instantiated transform.
	bottom = target_height + size.y
	# Debug info
	print_debug("bottom:")
	print_debug(bottom)
	
	# Make the rect for drawing where to put water disappear
	$ColorRect.hide()
	# Reference the polygon for drawing water
	water_polygon = $Polygon2DWater
	water_polygon.color = water_color
	water_border = $WaterBorder
	water_border.width = border_size
	
	# Get spring count based on size.x
	spring_count = round(size.x / distance_between_springs) + 1
	
	
	# Create springs for the water

	for i in range(spring_count):
		var x_position = distance_between_springs * i
		var new_spring = water_spring.instantiate()
		add_child(new_spring)
		springs.append(new_spring)
		if i < spring_count -1:
			new_spring._initialize(distance_between_springs * i)
		else:
			new_spring._initialize(size.x)

func _physics_process(delta):
	for spring in springs:
		spring._water_update(stiffness,dampening)
	var left_deltas: Array = []
	var right_deltas: Array = []
	# Set the values of left and right deltas to 0
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
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
	_new_border()				
	_draw_water_body()

			
func _splash(index,speed):
	if index >= 0 and index <= springs.size():
		springs[index].velocity += speed
		
func _draw_water_body():
	# Get teh curve of the border
	var curve = water_border.curve
	# Make an array of points from the curve
	var points = Array(curve.get_baked_points())
	
	var water_polygon_points = points
		
	var first_index: int = 0
	var last_index:int = water_polygon_points.size()-1

	water_polygon_points.append(Vector2(water_polygon_points[last_index].x,bottom))
	water_polygon_points.append(Vector2(water_polygon_points[first_index].x,bottom))
	water_polygon.set_polygon(PackedVector2Array(water_polygon_points))
	
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
	
	
