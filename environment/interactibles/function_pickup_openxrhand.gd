@tool
#@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRHandFunctionPickup
extends BoneAttachment3D

## XR Tools Function Pickup Script
##
## This script implements picking up of objects. Most pickable
## objects contain OpenXRGrabPointController


## Signal emitted when the pickup picks something up
signal picked_up(what)

## Signal emitted when the pickup drops something
signal dropped(what)

signal hand_pose_updated()


## Pickup enabled property
@export var enabled : bool = true


var _grab_point: XRGrabArea = null
var _picked_object: Node3D


var _skel_parent: Skeleton3D

func _enter_tree():
	if get_parent() as Skeleton3D:
		_skel_parent = get_parent()
		if get_child_count() > 0:
			$HandPoseRecognition.skeleton = _skel_parent
		get_parent().connect("bone_pose_changed", _on_Skeleton3D_bone_pose_changed, CONNECT_REFERENCE_COUNTED)


func _exit_tree():
	if get_parent() as Skeleton3D:
		_skel_parent = null
		get_parent().disconnect("pose_updated", _on_Skeleton3D_pose_updated)


func _ready():
	$HandPoseRecognition.skeleton = _skel_parent


func get_hand() -> Skeleton3D:
	return _skel_parent


func _on_Skeleton3D_bone_pose_changed(_bone_idx):
	emit_signal("hand_pose_updated")


func GetGrabPointsInRange() -> Array[XRGrabArea]:
	var result: Array[XRGrabArea] = []
	for obj in $GrabArea.get_overlapping_areas():
		result.push_back(obj as XRGrabArea)
	return result



func _on_hand_pose_recognition_new_pose(previous_pose: StringName, pose: StringName):
	$Label3D.text = str(pose)
	if _picked_object == null:
		var closest_grabbable_point = _get_closest_grabbable_point(previous_pose, pose)
		if closest_grabbable_point != null:
			_pick_up_object_has(closest_grabbable_point)
				
	elif previous_pose in _grab_point.pickup_poses and\
		not pose in _grab_point.pickup_poses:
			_drop_object()


func _get_closest_grabbable_point(previous_pose: StringName, pose: StringName) -> XRGrabArea:
	var closest_grabbable_point: XRGrabArea = null
	var closest_distance = INF
	for grab in GetGrabPointsInRange():
		var grabpoint_distance = grab.global_position.distance_squared_to(global_position)
		if grab.is_pickable() and\
			grabpoint_distance < closest_distance and\
			not previous_pose in grab.pickup_poses and\
			pose in grab.pickup_poses:
				closest_grabbable_point = grab
				closest_distance = grabpoint_distance
	return closest_grabbable_point


func _pick_up_object_has(grabpoint: XRGrabArea) -> void:
	_picked_object = grabpoint.picked_up(self)
	_grab_point = grabpoint
	emit_signal("picked_up", _picked_object)


## Drop the currently held object
func _drop_object() -> void:
	var obj = _picked_object
	_picked_object = null
	_grab_point.let_go()
	emit_signal("dropped", obj)


