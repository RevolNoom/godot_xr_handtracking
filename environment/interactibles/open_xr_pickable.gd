@tool
class_name OpenXRPickable_RigidBody3D
extends RigidBody3D


# Default layer for held objects is 17:held-object
const DEFAULT_PICKUP_LAYER := 0b0000_0000_0000_0001_0000_0000_0000_0000
## Layer for this object while picked up
@export_flags_3d_physics var picked_up_layer = DEFAULT_PICKUP_LAYER
@export_flags_3d_physics var picked_up_mask = 0

var original_collision_layer: int
var original_collision_mask: int

var pre_pick_up_hand_orientation: Basis
var pre_pick_up_self_orientation: Basis
var pre_pick_up_hand_to_self_offset: Vector3
var func_pick_up: XRHandFunctionPickup


func _on_grab_point_controller_picked_up(by_hand: XRHandFunctionPickup, _at_grab_point):
	freeze = true
	by_hand.connect("hand_pose_updated", _on_hand_pose_updated)
	
	func_pick_up = by_hand
	
	pre_pick_up_hand_orientation = by_hand.global_transform.basis.orthonormalized()
	pre_pick_up_self_orientation = global_transform.basis
	pre_pick_up_hand_to_self_offset = global_transform.origin - by_hand.global_transform.origin
	
	# Remember the mode before pickup
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

	collision_layer = picked_up_layer
	collision_mask = picked_up_mask


func _on_hand_pose_updated():
	var rot = func_pick_up.global_transform.basis.orthonormalized() * pre_pick_up_hand_orientation.inverse()
	var offset = rot * pre_pick_up_hand_to_self_offset 
	global_transform.origin = offset + func_pick_up.global_transform.origin
	global_transform.basis = rot * pre_pick_up_self_orientation

	
func _on_grab_point_controller_dropped(by_hand: XRHandFunctionPickup):
	freeze = false
	by_hand.disconnect("hand_pose_updated", _on_hand_pose_updated)
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer

