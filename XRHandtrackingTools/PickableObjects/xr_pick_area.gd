@tool
extends Area3D
class_name XRPickArea

# XRPickArea defines where an object can be picked and how
# There are three modes (Actually only two working currently):
# +) Pose Change Picking: Get picked up when XRPickupFunction
#	notices that the hand changed pose while it's in this XRPickArea.
#	The new hand pose must be in one of pose_change_pick_poses, while
#	the previous pose was not.
#	Note: Useful for grabbing gesture.
#	Example: Grabbing gun at blaster_dc_15.tscn
#
# +) Touch Picking: Get picked up when XRPickupFunction enters
#	this XRPickArea with the current hand pose in one of touch_pick_poses
#	Note: Not really sure in which general case it could be useful.
#		 I used it for grand_inquisitor_lightsaber.tscn, where the 
#		 lightsaber flies back like a boomerange, and this mode makes 
#		 catching it easier
#	Example: Catching boomerange at grand_inquisitor_lightsaber.tscn
#
# +) Ranged Picking [NOT IMPLEMENTED]: Works like Pose Change Picking,
#	but the picking distance is different. I intend to add a raycast
#	or something to XRPickupFunction. It's uncertain.
#
# NOTE: For more information about hand poses, check hand_pose_matcher


# TODO: Think about this: What if those enables
# are made physic layers instead?
@export var enabled = true

@export var enable_pose_change_picking := false
@export var pose_change_pick_poses: Array[StringName] = []

@export var enable_touch_picking := false
@export var touch_pick_poses: Array[StringName] = []

@export var enable_ranged_picking := false
@export var ranged_pick_poses: Array[StringName] = []


var _picker: XRPickupFunction = null


# Return the object this pick area is attached to
func get_object():
	return (get_parent() as XRPickAreaController).get_object()


# Return the first hand snap for corresponding hand or null
func get_hand_snap(hand: OpenXRHand.Hands) -> XRHandSnap:
	for child in get_children():
		if child is XRHandSnap and child.hand == hand:
			return child
	return null


func is_picked() -> bool:
	return _picker != null


func is_pickable() -> bool:
	return enabled and _picker == null and get_parent().can_pick_up()


# Notify XRPickAreaController that it's being picked up
# Return true if picked up successfully, false other wise
func picked_up(picker: XRPickupFunction) -> bool:
	if is_pickable():
		_picker = picker
		get_parent()._on_pickarea_picked_up(picker, self)
		return true
	return false


func ranged_picked_up(picker: XRPickupFunction) -> bool:
	if is_pickable():
		_picker = picker
		get_parent()._on_pickarea_ranged_picked_up(picker, self)
		return true
	return false


# Called by XRPickupFunction to notify object of being dropped
func let_go():
	if _picker == null:
		return
	var p = _picker
	_picker = null
	get_parent().let_go(p, self)


func _enter_tree():
	update_configuration_warnings()
	

func _get_configuration_warnings():
	if get_parent() is XRPickAreaController:
		return []
	return ["This node must be child of XRPickAreaController."]

