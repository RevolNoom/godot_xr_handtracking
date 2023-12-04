extends Area3D
class_name XRSnapArea

## This class snaps XRPickable's position and rotation to it.
## It assumes all objects entering are of class XRPickable
## Also, each XRPickable class must contains a node named SnapPoints and

## Snap XRPickable when they enter. Force XRPickupFunctions to drop the object
@export var snap_on_enter: bool = false
## Snap XRPickable when they exit. Force XRPickupFunctions to drop the object
@export var snap_on_exit: bool = false
## Snap XRPickable when they are not picked up by any hand anymore
@export var snap_on_dropped: bool = true

## If true, on snapping, move XRPickable so that the nearest snap point 
## (nearest XRPickable's "SnapPoints"'s child) has same global position 
## with XRSnapArea
@export var snap_position = true
## If true, on snapping, rotate XRPickable so that the nearest snap point 
## (nearest XRPickable's "SnapPoints"'s child) has same global rotation 
## with XRSnapArea
@export var snap_rotation = true
## How fast XRPickable will snap to XRSnapArea
@export_range(0, INF) var snap_duration : float = 0

func _ready():
	update_configuration_warnings()

func _on_body_entered(body: XRPickable):
	if snap_on_enter:
		body.slip_away()
		_snap(body)
	if snap_on_dropped:
		body.dropped.connect(_on_xr_pickable_dropped)


func _on_body_exited(body: XRPickable):
	if snap_on_exit:
		if body.is_picked():
			body.slip_away()
			## If snap_on_dropped == true, slip_away() already triggers snapping
			if not snap_on_dropped:
				_snap(body)
		else:
			_snap(body)
	else:
		body.dropped.disconnect(_on_xr_pickable_dropped)

func _on_xr_pickable_dropped(body: XRPickable, _picker: XRPickupFunction, _pickarea: XRPickArea):
	_snap(body)


func _snap(body: XRPickable):
	# Because we shouldn't touch directly on physic thread
	call_deferred("_deferred_snap", body)


func _deferred_snap(body: XRPickable):
	body.freeze = true
	if snap_position or snap_rotation:
		var nearest_snap_point = _get_nearest_snap_point(body)
		var final_transform: Transform3D = body.global_transform
		if snap_position:
			final_transform.origin = global_position \
				+ (body.global_position - nearest_snap_point.global_position)
		## TODO: Work out the math for snap_rotation
		#if snap_rotation:
		#	final_transform.basis = global_transform.quaternion \
		#		+ (body.global_position - nearest_snap_point.global_position)
		#	pass
		var tween = get_tree().create_tween()
		tween.tween_property(body, "global_transform", final_transform, snap_duration)


## Return the nearest snap point, or null if there's none
func _get_nearest_snap_point(body: XRPickable) -> Node3D:
	var sp = body.get_node_or_null("SnapPoints")
	if sp == null || sp.get_child_count() == 0:
		return null
	
	var nearest = sp.get_child(0)
	for i in range(1, sp.get_child_count()):
		var spoint = sp.get_child(i)
		if global_position.distance_squared_to(spoint.global_position)\
		< global_position.distance_squared_to(nearest.global_position):
			nearest = spoint
	return nearest


func unsnap(body: XRPickable):
	body.freeze = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	var pickable_layer = GodotXRHandtrackingToolkit.get_layer_index("pickable") 
	if pickable_layer == -1:
		warnings.append("""Physic layer 'pickable' not found in 
		"Project > Project Settings > Layer Names > 3D Physic".""") 
	else:
		if collision_mask & (1 << pickable_layer) == 0:
			warnings.append("""Collision mask should contain "pickable" layer 
			(layer %d)""" % (pickable_layer+1))
			
		if collision_mask & ~(1 << pickable_layer) != 0:
			warnings.append("""XRSnapArea assumes all objects entering it 
			are of class XRPickable. You should turn on only layer %d and 
			ignore the rest""" % (pickable_layer+1))
	return warnings

func _on_property_list_changed():
	update_configuration_warnings()
