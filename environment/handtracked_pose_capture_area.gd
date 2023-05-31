@tool
extends Area3D

# I intended this to capture bone positions
# For hand pose recognization
# But it's unnecessary now


func _ready():
	$PoseName.text = name
	

func _on_body_entered(body):
	if not body is PhysicalBone3D:
		return
	$Timer.start()
	set_process(true)

func _on_body_exited(body):
	if not body is PhysicalBone3D:
		return
	if get_overlapping_bodies().size() == 0:
		$Timer.stop()
		$TimeLeft.text = "0"
		set_process(false)


func _process(_delta):
	$TimeLeft.text = str(round($Timer.time_left))


func _on_timer_timeout():
	var a_random_bone = get_overlapping_bodies()[0]
	var skeleton = a_random_bone.get_parent() as Skeleton3D
	var openxr_hand = skeleton.get_parent() as OpenXRHand
	var pose_info: Dictionary = {
		"left_hand": openxr_hand.hand == openxr_hand.HAND_LEFT,
		"pose_name": $PoseName.text,
		"bone_pos":{}}
	for b in range(0, skeleton.get_bone_count()):
		var bone_pos = skeleton.get_bone_pose_position(b)
		# Setting as Array to be able to save into JSON
		pose_info["bone_pos"][b] = [bone_pos.x, bone_pos.y, bone_pos.z]

	print(pose_info)
