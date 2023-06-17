@tool
class_name XRPickableRigidBody
extends RigidBody3D


# NOTE: Use freeze_mode = Kinematic for this RigidBody3D


signal picked(_self, by_hand: XRPickupFunction, at_grab_point: XRPickArea)
signal dropped(_self, by_hand: XRPickupFunction)


# Default layer for held objects is 17:held-object
const DEFAULT_PICKUP_LAYER: int = 0b0000_0000_0000_0001_0000_0000_0000_0000
## Layer for this object while picked up
@export_flags_3d_physics var picked_up_layer: int = DEFAULT_PICKUP_LAYER
@export_flags_3d_physics var picked_up_mask: int = 0


var original_collision_layer: int
var original_collision_mask: int


var pre_pick_up_hand_orientation: Basis
var pre_pick_up_self_orientation: Basis
var pre_pick_up_hand_to_self_offset: Vector3
var picker: XRPickupFunction


func _on_pick_area_controller_picked_up(by_hand: XRPickupFunction, at_grab_point: XRPickArea):
	freeze = true
	$VelocityAverager3D.enabled = true
	by_hand.connect("transform_updated", _on_hand_transform_updated)
	
	picker = by_hand
	
	pre_pick_up_hand_orientation = by_hand.global_transform.basis.orthonormalized()
	pre_pick_up_self_orientation = global_transform.basis
	pre_pick_up_hand_to_self_offset = global_transform.origin - by_hand.global_transform.origin
	
	# Remember the mode before pickup
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

	collision_layer = picked_up_layer
	collision_mask = picked_up_mask
	
	emit_signal("picked", self, by_hand, at_grab_point)


func _on_hand_transform_updated():
	var rot = picker.global_transform.basis.orthonormalized() * pre_pick_up_hand_orientation.inverse()
	var offset = rot * pre_pick_up_hand_to_self_offset 
	global_transform.origin = offset + picker.global_transform.origin
	global_transform.basis = rot * pre_pick_up_self_orientation

	
func _on_pick_area_controller_dropped(by_hand: XRPickupFunction):
	freeze = false
	$VelocityAverager3D.enabled = false
	by_hand.disconnect("transform_updated", _on_hand_transform_updated)
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer
	
	linear_velocity = $VelocityAverager3D.average_linear_velocity()
	angular_velocity = $VelocityAverager3D.average_angular_velocity()

	emit_signal("dropped", self, by_hand)
