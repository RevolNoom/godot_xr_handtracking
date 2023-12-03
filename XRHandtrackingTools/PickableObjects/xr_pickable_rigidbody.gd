@tool

## This RigidBody3D supports:
## +) Hand Picking
## +) Throwing when released by hand
## To support hand snapping when picking objects, add XRHandSnap to XRPickArea
class_name XRPickable
extends RigidBody3D



## Emitted when @picker range-pick up object at @pick_area
signal ranged_picked(_self, picker: XRPickupFunction, pick_area: XRPickArea)
## Emitted when @picker pick up object at @pick_area
signal picked(_self, picker: XRPickupFunction, pick_area: XRPickArea)
## Emitted when @picker dropped object from @pick_area
signal dropped(_self, picker: XRPickupFunction, pick_area: XRPickArea)

# See Mux123's Godot XR Tools for more detailed explanation
# Default layer for held objects is 17:held-object
const DEFAULT_PICKUP_LAYER: int = 0b0000_0000_0000_0001_0000_0000_0000_0000
## Physic layer of the object when it's picked up
@export_flags_3d_physics var picked_up_layer: int = DEFAULT_PICKUP_LAYER
## Physic mask of the object when it's picked up
@export_flags_3d_physics var picked_up_mask: int = 0

## If custom_movement = true, 
## you may override _on_hand_transform_updated() to move it your way
@export var custom_movement = true 


var _original_collision_layer: int
var _original_collision_mask: int
var _global_transform_relative_to_picker := Transform3D()


func _on_pick_area_controller_picked_up(picker: XRPickupFunction, at_pickarea: XRPickArea):
	freeze = true
	# Remember the mode before pickup
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	collision_layer = picked_up_layer
	collision_mask = picked_up_mask
	
	# Check for hand snaps
	# And re-orient this object so that the XRHandSnap
	# has identical transform to the hand
	_snap_transform(picker, at_pickarea)
	
	# If you want to control the object movement directly
	# comment out this line
	if custom_movement:
		picker.connect("transform_updated", _on_hand_transform_updated)
	else:
		picker.takeover_movement_control(self)
	
	_global_transform_relative_to_picker.origin =\
			global_transform.origin - picker.global_transform.origin
	_global_transform_relative_to_picker.basis =\
			(picker.global_transform.basis.inverse()\
			* global_transform.basis)\
				.orthonormalized()
	
	emit_signal("picked", self, picker, at_pickarea)


# Almost perfect copy of picked_up version
# Differs in signal emitted
# Of course, you are welcome to implement it anyhow you like
func _on_pick_area_controller_ranged_picked_up(picker: XRPickupFunction, at_pickarea: XRPickArea):
	freeze = true
	# Remember the mode before pickup
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	collision_layer = picked_up_layer
	collision_mask = picked_up_mask
	
	# Check for hand snaps
	# And re-orient this object so that the XRHandSnap
	# has identical transform to the hand
	_snap_transform(picker, at_pickarea)
	
	# If you want to control the object movement directly
	# comment out this line
	if custom_movement:
		picker.takeover_movement_control(self)
	else:
		picker.connect("transform_updated", _on_hand_transform_updated)
	
	_global_transform_relative_to_picker.origin =\
			global_transform.origin - picker.global_transform.origin
	_global_transform_relative_to_picker.basis =\
			(picker.global_transform.basis.inverse()\
			* global_transform.basis)\
				.orthonormalized()
	
	emit_signal("ranged_picked", self, picker, at_pickarea)


## OVERRIDE ME!
func _on_hand_transform_updated(_picker: XRPickupFunction):
	global_transform = _picker.global_transform * _global_transform_relative_to_picker


func _on_pick_area_controller_dropped(picker: XRPickupFunction, at_pickarea: XRPickArea):
	freeze = false
	collision_mask = _original_collision_mask
	collision_layer = _original_collision_layer
	
	if custom_movement:
		picker.disconnect("transform_updated", _on_hand_transform_updated)
	
	# Throw behavior
	# Comment them out to make things just drop lifelessly
	linear_velocity = picker.get_linear_velocity()
	angular_velocity =  picker.get_angular_velocity()
	
	emit_signal("dropped", self, picker, at_pickarea)


# Check for hand snaps
# And re-orient this object so that the XRHandSnap
# has identical transform to the hand
func _snap_transform(picker: XRPickupFunction, pickarea: XRPickArea):
	var snap = pickarea.get_hand_snap(picker.get_hand())
	if snap:
		global_transform.basis = picker.global_transform.basis.orthonormalized()\
				* snap.global_transform.basis.inverse().orthonormalized()\
				* global_transform.basis
		global_position += picker.global_position - snap.global_position



func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	var xr_pac: XRPickAreaController = null
	if freeze_mode != FREEZE_MODE_KINEMATIC:
		warnings.append("""freeze_mode should be Kinematic.""")
	
	var snap_points = get_node_or_null("SnapPoints")
	if snap_points == null:
		warnings.append("""Consider adding a Node3D named "SnapPoints" to
		work with XRSnapArea. You may ignore or comment out this warning.""")
	elif snap_points.get_child_count() == 0:
		warnings.append("""No snap point found. Consider adding some Marker3Ds 
		as children of "SnapPoints" and configure their transform to work
		with XRSnapArea""")
		
	for child in get_children():
		if child is XRPickAreaController:
			xr_pac = child
			break
	if xr_pac == null:
		warnings.append("""Child XRPickAreaController not found. 
		An XRPickAreaController controls XRPickAreas (where your hand can 
		interact) for this object.""")
	else:
		if xr_pac.dropped.get_connections().size() == 0:
			warnings.append("""XRPickAreaController's 'dropped' signal is not
			connected to _on_pick_area_controller_dropped. This object
			 won't get notified of XRTrackedHand's dropping actions""")
		if xr_pac.picked_up.get_connections().size() == 0\
			and xr_pac.ranged_picked_up.get_connections().size() == 0:
			warnings.append("""Both XRPickAreaController's 'picked_up' and 
			'ranged_picked_up' signals aren't connected to _
			on_pick_area_controller_(ranged_)picked_up. This object won't be
			notified of XRTrackedHand's picking actions""")
			
	var pickable_layer = GodotXRHandtrackingToolkit.get_layer_index("pickable")
	if pickable_layer == -1:
		warnings.append("""Physic layer 'pickable' not found in 
		"Project > Project Settings > Layer Names > 3D Physic".""") 
	elif collision_layer & (1 << pickable_layer) == 0:
		warnings.append("""All (and Only) XRPickable objects should be in 'pickable' 
		collision layer (layer %d). If this is intended, please kindly ignore
		or comment out this message. If it's not and you want to disable picking 
		behavior, you should disable XRPickAreaController instead""" % pickable_layer)
	return warnings

func _on_property_list_changed():
	update_configuration_warnings()

