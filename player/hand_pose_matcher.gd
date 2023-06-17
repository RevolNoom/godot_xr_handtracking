@tool
class_name HandPoseMatcher
extends Node


signal new_pose(previous_pose: StringName, pose: StringName)


const POSITION = 0
const ROTATION = 1

@export_enum("left", "right") var hand: String = "left":
	set(value):
		hand = value


@export var skeleton: Skeleton3D = null:
	set(skel):
		skeleton = skel
		set_process(hand_pose_templates != "" and skeleton != null and not Engine.is_editor_hint())


# Used to prevent jittering between two poses 
# Currently USELESS
@export var pose_stabilize_const = 0.01

@export_file("*.json") var hand_pose_templates: String = "":
	set(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var result = JSON.parse_string(file.get_as_text())
			if result:
				hand_pose_templates = file_path
				supported_poses = result
				for k_hand in supported_poses.keys():
					for pose in supported_poses[k_hand].keys():
						for bone in supported_poses[k_hand][pose].keys():
							var v = supported_poses[k_hand][pose][bone]
							supported_poses[k_hand][pose][bone] = [null, null]
							supported_poses[k_hand][pose][bone][POSITION] = Vector3(v[0], v[1], v[2])
							supported_poses[k_hand][pose][bone][ROTATION] = Quaternion(v[3], v[4], v[5], v[6])
				
			else:
				hand_pose_templates = ""
				supported_poses = {}
				printerr("Can't parse " + str(file_path) + " into JSON for HandPoseRecognition.")
		else:
			hand_pose_templates = ""
			supported_poses = {}
			printerr("Can't open file " + file_path)
		
		set_process(hand_pose_templates != "" and skeleton != null and not Engine.is_editor_hint())


@export var supported_poses: Dictionary = {}

# Poses from supported_poses that the user specifies in editor
# for recognization
# Leave empty to try recognize all poses
@export var poses_allowed_to_recognize: PackedStringArray


var current_pose: StringName = ""
var previous_pose: StringName = ""


func _enter_tree():
	if poses_allowed_to_recognize.size():
		current_pose = poses_allowed_to_recognize[0]
	else:
		current_pose = supported_poses[hand].keys().pick_random()
		

func _get_skeleton_pose() -> Dictionary:
	if skeleton == null:
		return {}
	var result = {}
	for i in range(0, skeleton.get_bone_count()):
		var p = skeleton.get_bone_global_pose(i)
		result[str(i)] = [p.origin, p.basis.get_rotation_quaternion()]
	return result


func _find_pose_most_similar_to_current_skeleton() -> StringName:
	var best_match_pose: StringName
	var best_difference: float = INF
	
	var skel = _get_skeleton_pose()
	
	var poses_to_match = poses_allowed_to_recognize
	if poses_to_match.size() == 0:
		poses_to_match = supported_poses[hand].keys()
		
	for pose in poses_to_match:
		var difference = HandPoseMatcher.calculate_difference(skel, supported_poses[hand][pose])
		
		if difference < best_difference:
			best_match_pose = pose
			best_difference = difference

	return best_match_pose


# Each pose is a dictionary that contains Vector3
static func calculate_difference(pose1: Dictionary, pose2: Dictionary) -> float:
	var difference = 0.0
	for bone in pose1.keys():
		var pos_diff = (pose1[bone][POSITION] as Vector3).distance_to(pose2[bone][POSITION])
		var rot_diff = (pose1[bone][ROTATION] as Quaternion).angle_to(pose2[bone][ROTATION])
		difference += abs(pos_diff * rot_diff + pos_diff + rot_diff)
	return difference


func _process(_delta):
	var recognized_pose: StringName = _find_pose_most_similar_to_current_skeleton()
	if recognized_pose != current_pose:
		previous_pose = current_pose
		current_pose = recognized_pose
		emit_signal("new_pose", previous_pose, recognized_pose)
