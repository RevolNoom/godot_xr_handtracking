@tool
extends Node3D

class_name XRPickable


var pre_pick_up_hand_orientation: Basis
var pre_pick_up_self_orientation: Basis
var pre_pick_up_hand_to_self_offset: Vector3
var func_pick_up: XRPickupFunction


func _on_grab_point_controller_picked_up(by_hand: XRPickupFunction, _at_grab_point):
	by_hand.connect("hand_pose_updated", _on_hand_pose_updated)
	
	func_pick_up = by_hand
	
	pre_pick_up_hand_orientation = by_hand.global_transform.basis.orthonormalized()
	pre_pick_up_self_orientation = global_transform.basis
	pre_pick_up_hand_to_self_offset = global_transform.origin - by_hand.global_transform.origin
	

func _on_hand_pose_updated():
	var rot = func_pick_up.global_transform.basis.orthonormalized() * pre_pick_up_hand_orientation.inverse()
	var offset = rot * pre_pick_up_hand_to_self_offset 
	global_transform.origin = offset + func_pick_up.global_transform.origin
	global_transform.basis = rot * pre_pick_up_self_orientation

	
func _on_grab_point_controller_dropped(by_hand: XRPickupFunction):
	by_hand.disconnect("hand_pose_updated", _on_hand_pose_updated)

