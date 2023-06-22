@tool
class_name XRPickableRigidBody
extends RigidBody3D


# NOTE: Use freeze_mode = Kinematic for this RigidBody3D


signal picked(_self, by_hand: XRPickupFunction, at_grab_point: XRPickArea)
signal dropped(_self, by_hand: XRPickupFunction, at_grab_point: XRPickArea)


# Default layer for held objects is 17:held-object
const DEFAULT_PICKUP_LAYER: int = 0b0000_0000_0000_0001_0000_0000_0000_0000
## Layer for this object while picked up
@export_flags_3d_physics var picked_up_layer: int = DEFAULT_PICKUP_LAYER
@export_flags_3d_physics var picked_up_mask: int = 0


var original_collision_layer: int
var original_collision_mask: int


var pick_info:= PickInfo.new()


func _on_pick_area_controller_picked_up(by_hand: XRPickupFunction, pick_area: XRPickArea):
	freeze = true
	$VelocityAverager3D.enabled = true
	
	# Check for hand snaps
	# And re-orient this object so that the XRHandSnap
	# has identical transform
	var snap = pick_area.get_hand_snap(by_hand.get_hand())
	if snap:
		global_transform.basis = by_hand.global_transform.basis.orthonormalized()\
				* snap.global_transform.basis.inverse().orthonormalized()\
				* global_transform.basis
		global_position += by_hand.global_position - snap.global_position
	
	
	pick_info.picker = by_hand
	pick_info.picker.connect("transform_updated", _on_hand_transform_updated)
	pick_info.picker_org_rot = pick_info.picker.global_transform.basis.orthonormalized()
	pick_info.self_org_rot = global_transform.basis
	pick_info.picker_self_offset = global_transform.origin - pick_info.picker.global_transform.origin


	# Remember the mode before pickup
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

	collision_layer = picked_up_layer
	collision_mask = picked_up_mask
	
	emit_signal("picked", self, by_hand, pick_area)


func _on_hand_transform_updated(_picker):
	var rot = pick_info.picker.global_transform.basis.orthonormalized() * pick_info.picker_org_rot.inverse()
	var offset = rot * pick_info.picker_self_offset
	global_transform.origin = offset + pick_info.picker.global_transform.origin
	global_transform.basis = rot * pick_info.self_org_rot


func _on_pick_area_controller_dropped(by_hand: XRPickupFunction, pick_point: XRPickArea):
	freeze = false
	$VelocityAverager3D.enabled = false
	by_hand.disconnect("transform_updated", _on_hand_transform_updated)
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer
	
	linear_velocity = $VelocityAverager3D.average_linear_velocity()
	#print("Throw linear_velocity: " + str(linear_velocity))
	#print("distances deltas: " + str($VelocityAverager3D._linear_distances))
	angular_velocity = $VelocityAverager3D.average_angular_velocity()
	#print("Throw angular_velocity: " + str(linear_velocity))

	emit_signal("dropped", self, by_hand, pick_point)


class PickInfo:
	var picker: XRPickupFunction
	var picker_org_rot: Basis	# Picker's rotation at pick-up moment
	var self_org_rot: Basis	# Self's rotation at pick-up moment
	var picker_self_offset: Vector3
