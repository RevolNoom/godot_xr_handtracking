@tool
class_name XRPickupFunction
extends BoneAttachment3D

## XR Tools Function Pickup Script
##
## This script implements picking up of objects. Most pickable
## objects contain XRPickAreaController


## Signal emitted when the pickup picks something up
signal picked_up(what)
## Signal emitted when the pickup drops something
signal dropped(what)
signal pose_updated(prev_pose: StringName, current_pose: StringName)
signal transform_updated(_self)


## Pickup enabled property
@export var enabled : bool = true


var _pickarea: XRPickArea = null
var _picked_object: Node3D


func _enter_tree():
	if get_parent() as Skeleton3D:
		get_parent().connect("bone_pose_changed", _on_Skeleton3D_bone_pose_changed)


#func _exit_tree():
#	if get_parent() as Skeleton3D:
#		get_parent().disconnect("bone_pose_changed", _on_Skeleton3D_bone_pose_changed)


func _ready():
	$HandPoseMatcher.skeleton = get_parent()

# ASSUMPTION: 
# The lineage is OpenXRHand -> Skeleton3D -> XRPickupFunction
func get_hand() -> OpenXRHand.Hands:
	return (get_parent().get_parent() as OpenXRHand).hand


func _on_Skeleton3D_bone_pose_changed(_bone_idx):
	emit_signal("transform_updated", self)


func _get_pickareas_in_range() -> Array[XRPickArea]:
	var result: Array[XRPickArea] = []
	for obj in $GrabArea.get_overlapping_areas():
		result.push_back(obj as XRPickArea)
	return result


func _on_hand_pose_matcher_new_pose(previous_pose: StringName, pose: StringName):
	$Label3D.text = str(pose)
	if _picked_object == null:
		var closest_grabbable = _get_closest_pickable(
								_get_pose_change_pickareas())
								
		if closest_grabbable != null:
			_pick_up_object_has(closest_grabbable)
				
	elif not pose in _pickarea.pose_change_pick_poses:
		_drop_object()
			
	emit_signal("pose_updated", previous_pose, pose)


func _on_grab_area_area_entered(_area: Area3D):
	if _picked_object == null:
		var closest_grabbable = _get_closest_pickable(
								_get_touch_pickareas())
		if closest_grabbable != null:
			_pick_up_object_has(closest_grabbable)


func _on_grab_area_area_exited(area):
	if _pickarea == area:
		_drop_object()


func _get_closest_pickable(grabareas: Array[XRPickArea]):
	var closest_obj: XRPickArea = null
	var closest_distance = INF
	for grab in grabareas:
		var distance = grab.global_position.distance_squared_to(global_position)
		if grab.is_pickable() and\
			distance < closest_distance:
				closest_obj = grab
				closest_distance = distance
	return closest_obj


func _get_touch_pickareas() -> Array[XRPickArea]:
	var result: Array[XRPickArea] = []
	for pickarea in _get_pickareas_in_range():
		if pickarea.enable_touch_picking and \
		$HandPoseMatcher.current_pose in pickarea.touch_pick_poses:
			result.push_back(pickarea)
	return result


func _get_pose_change_pickareas() -> Array[XRPickArea]:
	var result: Array[XRPickArea] = []
	for pickarea in _get_pickareas_in_range():
		if pickarea.enable_pose_change_picking and \
		$HandPoseMatcher.current_pose in pickarea.pose_change_pick_poses and\
		$HandPoseMatcher.previous_pose not in pickarea.pose_change_pick_poses:
			result.push_back(pickarea)
	return result


func _pick_up_object_has(pickarea: XRPickArea) -> void:
	_picked_object = pickarea.picked_up(self)
	_pickarea = pickarea
	emit_signal("picked_up", _picked_object)


## Drop the currently held object
func _drop_object() -> void:
	var obj = _picked_object
	_picked_object = null
	_pickarea.let_go()
	emit_signal("dropped", obj)
