@tool
extends Area3D
class_name XRPickArea

# XRPickArea defines Where and How an object can be picked
# To disable it from being picked up, disable "monitorable"
#
# There are three modes (Actually only two working currently):
# +) Pose Change Picking: Get picked up when XRPickupFunction
#	notices that the hand changed pose while it's in this XRPickArea.
#	The new hand pose must be in one of pose_change_pick_poses, while
#	the previous pose was not.
#	Note: Useful for grabbing gesture.
#	Example: Grabbing gun at blaster_dc_15.tscn
#
# +) Touch Picking: Get picked up when XRPickupFunction touch
#	this XRPickArea and its current hand pose is in one of touch_pick_poses
#	Note: Not really sure in which general case it could be useful.
#
# NOTE: For more information about hand poses, check hand_pose_matcher


@export var enable_pose_change_picking := false
@export var pose_change_pick_poses: Array[StringName] = []

@export var enable_touch_picking := false
@export var touch_pick_poses: Array[StringName] = []

@export var enable_ranged_picking := false
@export var ranged_pick_poses: Array[StringName] = []


var _picker: XRPickupFunction = null

func _ready():
	update_configuration_warnings()

# Return the first hand snap for corresponding hand 
# or null if there's no hand snap for it
func get_hand_snap(hand: OpenXRHand.Hands) -> XRHandSnap:
	for child in get_children():
		if child is XRHandSnap and child.hand == hand:
			return child
	return null


func is_picked() -> bool:
	return _picker != null


func is_pickable() -> bool:
	return _picker == null and get_parent().can_pick_up()


# Return true if picked up successfully, false other wise
func picked_up(picker: XRPickupFunction) -> bool:
	if is_pickable():
		_picker = picker
		get_parent()._on_pick_area_picked_up(picker, self)
		return true
	return false


# Return true if picked up successfully, false other wise
func ranged_picked_up(picker: XRPickupFunction) -> bool:
	if is_pickable():
		_picker = picker
		get_parent()._on_pick_area_ranged_picked_up(picker, self)
		return true
	return false


# Called by XRPickupFunction to notify object of being dropped
func dropped():
	if _picker == null:
		return
	var p = _picker
	_picker = null
	get_parent()._on_pick_area_dropped(p, self)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not (get_parent() is XRPickable):
		warnings.append("This node must be child of XRPickable.")
		
	var pickable_layer = GodotXRHandtrackingToolkit.get_layer_index("pickable")
	if pickable_layer == -1:
		warnings.append("""Physic layer 'pickable' not found in 
		"Project > Project Settings > Layer Names > 3D Physic".""") 
	elif collision_layer & (1 << pickable_layer) == 0:
		warnings.append("""Collision layer %d ('pickable') disabled.
		This XRPickArea won't react to pickup.""" % (pickable_layer+1))
		
	if not (enable_pose_change_picking || enable_ranged_picking || enable_touch_picking):
		warnings.append("""At least one of the pick mode
		must be turned on for the XRPickArea to work.""")
	else:
		for pick_mode in [[enable_pose_change_picking, pose_change_pick_poses.size(), "Pose-change"],
			[enable_ranged_picking, ranged_pick_poses.size(), "Ranged"],
			[enable_touch_picking, touch_pick_poses.size(), "Touch"]]:
			if pick_mode[0] and pick_mode[1] == 0:
				warnings.append("%s picking is enabled, but there's no pose assigned to it." % pick_mode[2])
	return warnings


func _on_property_list_changed():
	update_configuration_warnings()
