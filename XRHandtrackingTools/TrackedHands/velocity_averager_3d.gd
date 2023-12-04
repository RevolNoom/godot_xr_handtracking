class_name VelocityAverager3D
extends Node3D

# Extension of Velocity averager from Mux123's XRTools. 
# He wrote most of the code
#
# What it does:
# - Assists in calculating linear and angular velocities
# - Provides the average velocity calculated from the total
#	distance divided by the total time.
#
# What's new (compared to Mux's)?
# - It's a Node3D, used to stick to whatever you want. 
#	Process the average velocities automatically, you
#	don't have to manually push transformation from parent
#	node to it
# - Average in time, not in frames
# 
# I put a VelocityAverager3D to XRPickupFunction. You can use
# XRPickupFunction.get_linear_velocity() and get_angular_velocity()
# for throwing behaviors


# Time to average in seconds
@export var averaging_time : float = 0.2

# Turn on when needed. Save performance wherever you can
@export var enabled := true:
	set(enable):
		# Only clear when we switch off to on
		if not enabled and enable:
			clear()
		enabled = enable
		set_physics_process(enabled)


var _total_deltas: float = 0

# Array of time deltas (in float seconds)
var _time_deltas := PackedFloat32Array()

# Array of linear distances (Vector3 Castesian Distances)
var _linear_distances := PackedVector3Array()

# Array of angular distances (Vector3 Euler Distances)
var _angular_distances := PackedVector3Array()

# Because a transform degrades over time
# I need to re-orthonormalize it
const LAST_TRANSFORM_REFRESH_FREQUENCY = 100
var _last_transform_used_time := 0
@onready var _last_transform := global_transform


## Clear the averages
func clear():
	_total_deltas = 0
	_time_deltas.clear()
	_linear_distances.clear()
	_angular_distances.clear()
	_last_transform = global_transform


## Calculate the average linear velocity
func linear_velocity() -> Vector3:
	# Skip if no averages
	if _total_deltas <= 0:
		return Vector3.ZERO
	var total_distance = 0
	for distance in _linear_distances:
		total_distance += distance.length()

	return _sum_Vector3s(_linear_distances).normalized() * total_distance / _total_deltas


## Calculate the average angular velocity as a Vector3 euler-velocity
func angular_velocity() -> Vector3:
	# Skip if no averages
	if _total_deltas <= 0:
		return Vector3.ZERO

	# At first glance the following operations may look incorrect as they appear
	# to involve scaling of euler angles which isn't a valid operation.
	#
	# They are actually correct due to the value being a euler-velocity rather
	# than a euler-angle. The difference is that physics engines process euler
	# velocities by converting them to axis-angle form by:
	# - Angle-velocity: euler-velocity vector magnitude
	# - Axis: euler-velocity normalized and axis evaluated on 1-radian rotation
	#
	# The result of this interpretation is that scaling the euler-velocity
	# by arbitrary amounts only results in the angle-velocity changing without
	# impacting the axis of rotation.

	# Calculate the average euler-velocity
	return _sum_Vector3s(_angular_distances) / _total_deltas


func _sum_Vector3s(vec3s: PackedVector3Array):
	var total := Vector3.ZERO
	for term in vec3s:
		total += term
	return total


func _physics_process(delta):
	var linear_distance = global_transform.origin - _last_transform.origin
	var angular_distance := (global_transform.basis * _last_transform.basis.inverse()).get_euler()
	_add_distance(delta, linear_distance, angular_distance)
	
	_last_transform = global_transform
	_last_transform_used_time += 1
	if _last_transform_used_time >= LAST_TRANSFORM_REFRESH_FREQUENCY:
		_last_transform = _last_transform.orthonormalized()
		_last_transform_used_time = 0
		

## Add linear and angular distances to the averager
func _add_distance(delta: float, linear_distance: Vector3, angular_distance: Vector3):
	_total_deltas += delta
	
	while _total_deltas > averaging_time:
		_total_deltas -= _time_deltas[0]
		_time_deltas.remove_at(0)
		_linear_distances.remove_at(0)
		_angular_distances.remove_at(0)

	_time_deltas.push_back(delta)
	_linear_distances.push_back(linear_distance)
	_angular_distances.push_back(angular_distance)



