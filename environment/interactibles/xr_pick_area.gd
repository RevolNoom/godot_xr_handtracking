@tool
extends Area3D
class_name XRPickArea

# TODO: Think about it. What if those enables
# are grouped into physic layers instead?

@export var enabled = true
@export var enable_pose_change_picking := false
@export var pose_change_pick_poses: Array[StringName] = []
@export var enable_touch_picking := false
@export var touch_pick_poses: Array[StringName] = []

# TODO: CURRENTLY USELESS
@export var enable_ranged_picking := false
@export var ranged_pick_poses: Array[StringName] = []


var _grabbing_hand: XRPickupFunction = null


func _enter_tree():
	update_configuration_warnings()


# Return the object this pick area is attached to
func get_object():
	return get_parent().get_object()


# Return the first hand snap with corresponding hand
# or null
func get_hand_snap(hand: OpenXRHand.Hands) -> XRHandSnap:
	for child in get_children():
		if child is XRHandSnap and child.hand == hand:
			return child
	return null


func is_picked() -> bool:
	return _grabbing_hand != null


func is_pickable() -> bool:
	return enabled and _grabbing_hand == null and get_parent().can_pick_up()


# Return the object if it can be picked
# Otherwise returns null
func picked_up(by_hand: XRPickupFunction) -> Node3D:
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

