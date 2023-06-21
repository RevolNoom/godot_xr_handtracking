@tool
extends Area3D

class_name XRPickArea

@export var enabled = true
@export var pick_on_pose_change = true
@export var pick_on_touch = false
@export var pickup_poses: PackedStringArray = []


var _grabbing_hand: Node3D = null


func _enter_tree():
	update_configuration_warnings()


func get_object():
	return get_parent().get_object()


func is_picked() -> bool:
	return _grabbing_hand != null


func is_pickable() -> bool:
	return enabled and _grabbing_hand == null and get_parent().can_pick_up()


# Return the object if it can be picked
# Otherwise returns null
func picked_up(by_hand) -> Node3D:
	if is_pickable():
		_grabbing_hand = by_hand
		get_parent()._on_grabpoint_pick_up(by_hand, self)
		return get_object()
	return null


func let_go():
	if _grabbing_hand == null:
		return
	var gh = _grabbing_hand
	_grabbing_hand = null
	get_parent().let_go(gh, self)


func _get_configuration_warnings():
	if get_parent() is XRPickAreaController:
		return []
	return ["This node must be child of XRPickAreaController."]

