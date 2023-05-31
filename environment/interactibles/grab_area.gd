@tool
extends Area3D

class_name XRGrabArea
# PickupTransform contains transform to apply to RemoteTransform on OpenXRHand

@export var enabled = true
@export var pickup_poses: PackedStringArray = []
var _grabbing_hand: Node3D = null


func _enter_tree():
	update_configuration_warnings()


func get_object():
	return get_parent().get_object()


func is_pickable() -> bool:
	#print("Grabpoint can pick up? " + str(enabled and _grabbing_hand == null and get_parent().can_pick_up()))
	return enabled and _grabbing_hand == null and get_parent().can_pick_up()


# Return the object if it can be picked
# Otherwise returns null
func picked_up(by_hand) -> Node3D:
	if is_pickable():
		get_parent()._on_grabpoint_pick_up(by_hand, self)
		_grabbing_hand = by_hand
		return get_object()
	return null


func let_go():
	if _grabbing_hand == null:
		return
	var gh = _grabbing_hand
	_grabbing_hand = null
	get_parent().let_go(gh)


func _get_configuration_warnings():
	if get_parent() is XRGrabAreaController:
		return []
	return ["This node must be child of XRGrabAreaController."]
