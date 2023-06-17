@tool
extends Area3D

# I intended this to capture bone positions
# For hand pose recognization
# But it's unnecessary now

# pose_info is of format: 
#
# ["left" or "right"]["posename"][bone_idx] = 
# [x, y, z, quat_x, quat_y, quat_z, quat_w]
signal recorded(pose_info: Dictionary)


func _ready():
	$PoseName.text = name
	

func apply_pose_on_hand(hand: Skeleton3D, pose: Dictionary):
	for b in range(0, hand.get_bone_count()):
		var bone = pose[str(b)]
		var rot = Quaternion(bone[3], bone[4], bone[5], bone[6])
		hand.set_bone_pose_rotation(b, rot)

func _on_body_entered(_body):
	if get_overlapping_bodies().size() == 1:
		$Done.hide()
		$Hands.hide()
		$Timer.start()
		set_process(true)


func _on_body_exited(_body):
	if get_overlapping_bodies().size() == 0:
		$Done.hide()
		$Hands.show()
		$Timer.stop()
		$TimeLeft.text = "0"
		set_process(false)


func _process(_delta):
	$TimeLeft.text = str(round($Timer.time_left))


func _on_timer_timeout():
	$Done.show()
	var a_random_bone = get_overlapping_bodies()[0]
	var skeleton = a_random_bone.get_parent().get_parent() as Skeleton3D
	var openxr_hand = skeleton.get_parent() as OpenXRHand
	
	var leftness = "left" if openxr_hand.hand == openxr_hand.HAND_LEFT else "right"
	var pose_name = $PoseName.text
	var pose_info: Dictionary = {
		leftness: {pose_name: {}}}
	for b in range(0, skeleton.get_bone_count()):
		var bone_pos = skeleton.get_bone_pose_position(b)
		var bone_rot = skeleton.get_bone_pose_rotation(b)
		# Setting as Array to be able to save into JSON
		pose_info[leftness][pose_name][str(b)] = [bone_pos.x, bone_pos.y, bone_pos.z,
									bone_rot.x, bone_rot.y, bone_rot.z, bone_rot.w]

	apply_pose_on_hand($Hands.get_node(leftness), pose_info[leftness][pose_name])
	emit_signal("recorded", pose_info)


func _on_property_list_changed():
	$PoseName.text = name

