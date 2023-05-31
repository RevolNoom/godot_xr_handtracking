extends XROrigin3D

func _on_vr_keyboard_pressed(key: String):
	$Label3D.text = $Label3D.text + key


func _on_hand_pose_recognition_new_pose(previous_pose, pose):
	$TrackedHandLeft/Skeleton3D/Label3D.text = str(pose)
