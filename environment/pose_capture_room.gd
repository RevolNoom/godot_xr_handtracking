extends Node3D

# Capture the global transform of all bones for each hand pose
# Including: Position (Vector3), and Rotation (quaternion)
# The "global" transform of each bone is in respect to the Skeleton


var path_prefix = "res://addons/godot-xr-tools/hands/animations/"
var pose_infos = {"left": {}, 
				"right": {}}
				
var poses = ["Cup", "Default pose", "Straight", "Surfer", "Thumb",
				"Grip 1", "Grip 2", "Grip 3", "Grip 4", "Grip 5", "Grip Shaft", "Grip",
				"Hold", "Horns", "Metal", "Middle", "OK", "Peace",
				"Pinch Flat", "Pinch Large", "Pinch Middle", "Pinch Ring", "Pinch Tight",
				"Pinch Up", "PingPong", "Pinky", "Pistol", "Ring", "Rounded", 
				"Sign 1", "Sign 2", "Sign 3", "Sign 4", "Sign 5", "Sign_Point"]


@onready var left_hand = $XROrigin3D/Left/LeftHand
@onready var right_hand = $XROrigin3D/Right/RightHand
var timer_passes = 0
var pose: String =""


func _on_timer_timeout():
	if poses.size() == 0:
		$Timer.stop()
		var hand_pose_template = FileAccess.open("res://hand_poses.json", FileAccess.WRITE)
		
		var json_str = JSON.stringify(pose_infos)
		#Do some formatting to make it easier on the eyes
		json_str = json_str.replace(":{", ":\n{\n")
		json_str = json_str.replace("}", "\n}")
		json_str = json_str.replace(",\"", ",\n\"")
		hand_pose_template.store_string(json_str)
		hand_pose_template.flush()
		hand_pose_template.close()
		print("All poses captured")
		return
	
	# Setup pose for the next _process() callbacks
	if timer_passes % 2 == 0:
		pose = poses.back()
		var left_pose = load(path_prefix + "left/" + pose + ".res")
		var right_pose = load(path_prefix + "right/" + pose + ".res")
		
		left_hand.default_pose.open_pose = left_pose
		left_hand.default_pose.closed_pose = left_pose
		var lhat = left_hand.get_node("AnimationTree")
		lhat.tree_root.get_node("OpenHand").animation = pose
		lhat.tree_root.get_node("ClosedHand1").animation = pose
		lhat.tree_root.get_node("ClosedHand2").animation = pose
		
		right_hand.default_pose.open_pose = right_pose
		right_hand.default_pose.closed_pose = right_pose
		var rhat = right_hand.get_node("AnimationTree")
		rhat.tree_root.get_node("OpenHand").animation = pose
		rhat.tree_root.get_node("ClosedHand1").animation = pose
		rhat.tree_root.get_node("ClosedHand2").animation = pose
	
	# Get the result after animations
	else:
		pose_infos["left"][pose] = get_bone_infos(left_hand.get_node("Hand_Nails_L/Armature/Skeleton3D"))
		pose_infos["right"][pose]= get_bone_infos(right_hand.get_node("Hand_Nails_R/Armature/Skeleton3D"))
		poses.erase(pose)
	
	timer_passes += 1


func get_bone_infos(hand: Skeleton3D):
	var bone_info: Dictionary = {}
	for bone in range(0, hand.get_bone_count()):
		var q = hand.get_bone_global_pose(bone).basis.get_rotation_quaternion()
		var o = hand.get_bone_global_pose(bone).origin
		bone_info[bone] = [o.x, o.y, o.z, q.x, q.y, q.z, q.w]
	return bone_info
