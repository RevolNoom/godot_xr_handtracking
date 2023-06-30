@tool
class_name XRPickableRigidBody
extends RigidBody3D

# TODO: Use Transform3D to handle movement


# If the body cannot be picked up, your setup might be incomplete:
# +) Use freeze_mode = Kinematic
# +) Check that XRPickAreaController's 
#	picked_up and dropped are connected here
#
# This is a RigidBody3D that supports:
# +) Hand Picking
# +) Snapping to XRHandSnap when picked up
# +) Throwing when released by hand


signal ranged_picked(_self, picker: XRPickupFunction, at_pickarea: XRPickArea)
signal picked(_self, picker: XRPickupFunction, at_pickarea: XRPickArea)
signal dropped(_self, picker: XRPickupFunction, at_pickarea: XRPickArea)


# An object will get different physic layers and masks when picked up
# Because you might want your hand to collide with this object, but not
# when it's in your hand
# See Mux123's Godot XR Tools for more detailed explanation
# Default layer for held objects is 17:held-object
const DEFAULT_PICKUP_LAYER: int = 0b0000_0000_0000_0001_0000_0000_0000_0000
@export_flags_3d_physics var picked_up_layer: int = DEFAULT_PICKUP_LAYER
@export_flags_3d_physics var picked_up_mask: int = 0


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
	picker.takeover_movement_control(self)
	# and uncomment this part
	#picker.connect("transform_updated", _on_hand_transform_updated)
	
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
	picker.takeover_movement_control(self)
	# and uncomment this part
	#picker.connect("transform_updated", _on_hand_transform_updated)
	
	_global_transform_relative_to_picker.origin =\
			global_transform.origin - picker.global_transform.origin
	_global_transform_relative_to_picker.basis =\
			(picker.global_transform.basis.inverse()\
			* global_transform.basis)\
				.orthonormalized()
	
	emit_signal("ranged_picked", self, picker, at_pickarea)


func _on_hand_transform_updated(_picker: XRPickupFunction):
	global_transform = _picker.global_transform * _global_transform_relative_to_picker


func _on_pick_area_controller_dropped(picker: XRPickupFunction, at_pickarea: XRPickArea):
	freeze = false
	collision_mask = _original_collision_mask
	collision_layer = _original_collision_layer
	
	#picker.disconnect("transform_updated", _on_hand_transform_updated)
	
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

