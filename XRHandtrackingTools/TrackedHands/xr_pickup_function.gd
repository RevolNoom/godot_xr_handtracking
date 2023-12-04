@tool
class_name XRPickupFunction
extends BoneAttachment3D

# This class implements pickup feature by firstly recognise hand poses,
# and then match hand pose to each pick up cases (touching, hand pose
# change) to determine whether a pick up happens or not
#
# With this class, what you can get are linear and angular velocity
# of the bone that this XRPickupFunction attaches to. 
#
# Picking & Dropping behavior:
# + Picking by changing hand poses uses XRPickArea's pose_change_pick_poses,
#	touching use touch_pich_poses, and ranged picking uses ranged_pick_poses
#
# + Dropping considers only pose_change_pick_poses: If your hand pose doesn't
#	match any in pose_change_pick_poses, then the object is droppedg

signal picked_up(what)
signal ranged_picked_up(what)
signal dropped(what)
signal pose_updated(prev_pose: StringName, current_pose: StringName)
signal transform_updated(_self)


# TODO: Add Highlighting features


## Pickup enabled property
@export var enabled : bool = true


var _pickarea: XRPickArea = null
var _picked_object: Node3D


func _ready():
	$HandPoseMatcher.skeleton = get_parent() as Skeleton3D


func get_linear_velocity() -> Vector3:
	return $VelocityAverager3D.linear_velocity()


func get_angular_velocity() -> Vector3:
	return $VelocityAverager3D.angular_velocity()


# ASSUMPTION: 
# The lineage is OpenXRHand -> Skeleton3D -> XRPickupFunction
func get_hand() -> OpenXRHand.Hands:
	return (get_parent().get_parent() as OpenXRHand).hand


func takeover_movement_control(pickable: XRPickable):
	$PickedObjectTransform.global_transform = pickable.global_transform
	$PickedObjectTransform.remote_path = pickable.get_path()


func _on_Skeleton3D_bone_pose_changed(_bone_idx):
	emit_signal("transform_updated", self)


func _get_pickareas_in_range() -> Array[XRPickArea]:
	var result: Array[XRPickArea] = []
	for obj in $PickupArea.get_overlapping_areas():
		result.push_back(obj as XRPickArea)
	return result


func _on_hand_pose_matcher_new_pose(previous_pose: StringName, pose: StringName):
	$PoseName.text = str(pose)
	if enabled and _picked_object == null:
		var closest_pickarea = _get_closest_pickable_area(
								_get_pose_change_pickareas())
		
		if closest_pickarea != null:
			_pick_up_object_has(closest_pickarea, false)
			
		elif $RangedPointer.is_colliding():
			var pickarea = $RangedPointer.get_collider()
			if previous_pose not in pickarea.ranged_pick_poses\
					and pose in pickarea.ranged_pick_poses:
				_pick_up_object_has(pickarea, true)

	# Drop condition
	# I'm not sure about this. I feel like people will have different
	# needs when it comes to dropping behavior
	elif drop_condition_is_met(pose):
		drop_object()
			
	emit_signal("pose_updated", previous_pose, pose)


# +) Pick with what mode, drop with that mode
# +) _pickup_mode is on, but the enabled counterpart is off
# +) Current pose not in the counterpart's poses
func drop_condition_is_met(pose: StringName) -> bool:
	return not pose in _pickarea.pose_change_pick_poses


func _on_pickup_area_area_entered(_area: Area3D):
	#print("PickArea entered")
	if enabled and _picked_object == null:
		var closest_pickable = _get_closest_pickable_area(
								_get_touch_pickareas())
		if closest_pickable != null:
			_pick_up_object_has(closest_pickable, false)


func _on_pickup_area_area_exited(area):
	if _pickarea == area:
		drop_object()


func _get_closest_pickable_area(pickareas: Array[XRPickArea]):
	var closest_obj: XRPickArea = null
	var closest_distance = INF
	for pa in pickareas:
		var distance = pa.global_position.distance_squared_to(global_position)
		if pa.is_pickable() and\
			distance < closest_distance:
				closest_obj = pa
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


func _pick_up_object_has(pickarea: XRPickArea, ranged: bool) -> void:
	$RangedPointer.enabled = false
	if pickarea.picked_up(self):
		_picked_object = pickarea.get_parent()
		_pickarea = pickarea
		if ranged:
			emit_signal("ranged_picked_up", _picked_object)
		else:
			emit_signal("picked_up", _picked_object)


func drop_object():
	$PickedObjectTransform.remote_path = NodePath()
	$RangedPointer.enabled = true
	var obj = _picked_object
	_picked_object = null
	_pickarea.dropped()
	emit_signal("dropped", obj)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var pickable_layer = GodotXRHandtrackingToolkit.get_layer_index("pickable")
	if pickable_layer == -1:
		warnings.append("""Physic layer 'pickable' not found in 
		"Project > Project Settings > Layer Names > 3D Physic".""") 
	else:
		if $PickupArea.collision_mask & (1 << pickable_layer) == 0:
			warnings.append("""$PickArea collision mask should enable 'pickable' 
			layer (layer %d). If this is intended, please kindly ignore
			or comment out this message.""" % (pickable_layer+1))
		if not $PickupArea.monitoring:
			warnings.append("""$PickArea's "monitoring" is disabled.
			XRPickupFunction won't be able to identify XRPickAreas""")
	return []


func _enter_tree():
	if get_parent() as Skeleton3D:
		get_parent().connect("bone_pose_changed", _on_Skeleton3D_bone_pose_changed)


func _exit_tree():
	if get_parent() as Skeleton3D:
		get_parent().disconnect("bone_pose_changed", _on_Skeleton3D_bone_pose_changed)
