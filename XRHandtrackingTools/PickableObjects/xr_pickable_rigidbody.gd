@tool

## This RigidBody3D supports:
## +) Hand Picking
## +) Throwing when released by hand
## To support hand snapping when picking objects, add XRHandSnap to XRPickArea
class_name XRPickable
extends RigidBody3D


## Emitted every time a @picker ranged-pickup this object at @pick_area
signal ranged_picked(_self, picker: XRPickupFunction, pick_area: XRPickArea)
## Emitted every time a @picker pickup this object at @pick_area
signal picked(_self, picker: XRPickupFunction, pick_area: XRPickArea)
## Emitted when @picker dropped object from @pick_area
signal let_go(_self, picker: XRPickupFunction, pick_area: XRPickArea)
## Emitted when @picker is the last XRPickupFunction that hold onto this
## object
signal dropped(_self, picker: XRPickupFunction, pick_area: XRPickArea)

# See Mux123's Godot XR Tools for more detailed explanation
# Default layer for held objects is 17:held-object
const DEFAULT_PICKUP_LAYER: int = 0b0000_0000_0000_0001_0000_0000_0000_0000
## Physic layer of the object when it's picked up
@export_flags_3d_physics var picked_up_layer: int = DEFAULT_PICKUP_LAYER
## Physic mask of the object when it's picked up
@export_flags_3d_physics var picked_up_mask: int = 0

## Amount of XRPickArea that can be picked up simultaneously
@export_range(1, 99999) var simultaneous_pick: int = 1
## If true, allow children XRPickArea to be picked
## If false, disable children XRPickArea from being picked
@export var enabled : bool = true

## If custom_movement = true, 
## you may override _on_hand_transform_updated() to move it your way
@export var custom_movement = false 

## The XRPickupFunction that are holding this object
var _current_pickers: Array[XRPickupFunction] = []

## Physic layer of the object before it's picked up
var _original_collision_layer: int
## Physic mask of the object before it's picked up
var _original_collision_mask: int
## Relative transform to XRTrackedHand before it's picked up
var _global_transform_relative_to_picker := Transform3D()


## Test if this object can be picked up
func can_pick_up() -> bool:
	return enabled and _current_pickers.size() < simultaneous_pick

## Return true if this object is being held
func is_picked() -> bool:
	return _current_pickers.size() > 0

## Slip this object away from hands holding it
func slip_away():
	for picker in _current_pickers:
		picker.drop_object()


## OVERRIDE ME!
## Called by @pickarea when this object is picked up
func _on_pick_area_picked_up(picker: XRPickupFunction, pickarea: XRPickArea):
	#print("Picked up")
	# Skip if disabled or already picked up
	if not can_pick_up():
		return
	_current_pickers.push_back(picker)
	
	freeze = true
	# Remember the mode before pickup
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	collision_layer = picked_up_layer
	collision_mask = picked_up_mask
	
	# Check for hand snaps
	# And re-orient this object so that the XRHandSnap
	# has identical transform to the hand
	_snap_transform(picker, pickarea)
	
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
	
	emit_signal("picked", self, picker, pickarea)


## OVERRIDE ME!
## Almost perfect copy of picked_up version
## Differs in signal emitted
## Of course, you are welcome to implement it anyhow you like
## Called by @pickarea when this object is ranged-picked
func _on_pick_area_ranged_picked_up(picker: XRPickupFunction, pickarea: XRPickArea):
	#print("Ranged picked up")
	
	# Skip if disabled or already picked up
	if not can_pick_up():
		return
	_current_pickers.push_back(picker)
	
	freeze = true
	# Remember the mode before pickup
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	collision_layer = picked_up_layer
	collision_mask = picked_up_mask
	
	# Check for hand snaps
	# And re-orient this object so that the XRHandSnap
	# has identical transform to the hand
	_snap_transform(picker, pickarea)
	
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
	
	emit_signal("ranged_picked", self, picker, pickarea)


## OVERRIDE ME!
func _on_hand_transform_updated(_picker: XRPickupFunction):
	global_transform = _picker.global_transform * _global_transform_relative_to_picker


## OVERRIDE ME!
## Called when this object is dropped
func _on_pick_area_dropped(picker: XRPickupFunction, pickarea: XRPickArea):
	_current_pickers.erase(picker)
	freeze = false
	collision_mask = _original_collision_mask
	collision_layer = _original_collision_layer
	
	if custom_movement:
		picker.disconnect("transform_updated", _on_hand_transform_updated)
	
	# Throw behavior
	# Comment them out to make this object drops lifelessly
	linear_velocity = picker.get_linear_velocity()
	angular_velocity =  picker.get_angular_velocity()
	
	emit_signal("let_go", self, picker, pickarea)
	if _current_pickers.size() == 0:
		emit_signal("dropped", self, picker, pickarea)


## Check for hand snaps and re-orient this object
## so that the XRHandSnap has identical transform to the hand
func _snap_transform(picker: XRPickupFunction, pickarea: XRPickArea):
	var snap = pickarea.get_hand_snap(picker.get_hand())
	if snap:
		global_transform.basis = picker.global_transform.basis.orthonormalized()\
				* snap.global_transform.basis.inverse().orthonormalized()\
				* global_transform.basis
		global_position += picker.global_position - snap.global_position


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
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
	
	var pickable_layer = GodotXRHandtrackingToolkit.get_layer_index("pickable")
	if pickable_layer == -1:
		warnings.append("""Physic layer 'pickable' not found in 
		"Project > Project Settings > Layer Names > 3D Physic".""") 
	elif collision_layer & (1 << pickable_layer) == 0:
		warnings.append("""Collision layer %d ('pickable') disabled.
		This object will not react to pickup.""" % (pickable_layer+1))

	if simultaneous_pick > 1:
		warnings.append("""Remember to implement dual-hand object movement. 
		You may comment out this warning""")
	
	var missing_pick_area = true
	for child in get_children():
		if child is XRPickArea:
			missing_pick_area = false
	
	if missing_pick_area:
		warnings.append("Please add some children XRPickArea.")

	return warnings

func _on_property_list_changed():
	update_configuration_warnings()

func _on_child_entered_tree(_node):
	update_configuration_warnings()

func _on_child_exiting_tree(_node):
	update_configuration_warnings()
