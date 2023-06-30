@tool
class_name HandPoseMatcher
extends Node

# A HandPoseMatcher compares the bones positions, rotations in
# a Skeleton3D to a database of poses (JSON file of recorded
# poses from PoseRecordingRoom).
#
# If it doesn't match anything, make sure you have given 
# hand_pose_templates a valid json

signal new_pose(previous_pose: StringName, pose: StringName)


const POSITION = 0
const ROTATION = 1



@export_enum("left", "right") var hand: String = "left":
	set(value):
		hand = value


# The Skeleton3D that needs its pose identified
#
# NOTE: I assumed the following hierachy:
# OpenXRHand - Skeleton3D - XRPickupFunction - HandPoseMatcher
#
# So this property is already assigned by XRPickupFunction on its _ready()
# Modify that if you have other needs
@export var skeleton: Skeleton3D = null:
	set(skel):
		skeleton = skel
		set_process(hand_pose_templates != ""\
				and skeleton != null\
				and not Engine.is_editor_hint())

# TODO: Used to prevent jittering between two poses 
# Currently USELESS
@export var pose_stabilize_const = 0.01

@export_file("*.json") var hand_pose_templates: String = "":
	set(file_path):
		hand_pose_templates = ""
		supported_poses = {}
		poses_to_recognize= {}
		
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var result = JSON.parse_string(file.get_as_text())
			if result:
				hand_pose_templates = file_path
				supported_poses = result
				for k_hand in supported_poses.keys():
					poses_to_recognize[k_hand] = {}
					for pose in supported_poses[k_hand].keys():
						poses_to_recognize[k_hand][pose] = true
						for bone in supported_poses[k_hand][pose].keys():
							var v = supported_poses[k_hand][pose][bone]
							supported_poses[k_hand][pose][bone] = [null, null]
							supported_poses[k_hand][pose][bone][POSITION] = Vector3(v[0], v[1], v[2])
							supported_poses[k_hand][pose][bone][ROTATION] = Quaternion(v[3], v[4], v[5], v[6])
				
				
			else:
				printerr("Can't parse " + str(file_path) + " into JSON for HandPoseRecognition.")
		else:
			printerr("Can't open file " + file_path)
		
		set_process(hand_pose_templates != ""\
				and skeleton != null\
				and not Engine.is_editor_hint())


# Poses from supported_poses that the user specifies in editor
@export var poses_to_recognize:= {}

var supported_poses: Dictionary = {}

var current_pose: StringName = ""
var previous_pose: StringName = ""


func _ready():
	set_process(hand_pose_templates != ""\
			and skeleton != null\
			and not Engine.is_editor_hint())
		
		

func _get_skeleton_pose() -> Dictionary:
	if skeleton == null:
		#print("null skeleton")
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
		
	for pose in poses_to_recognize[hand].keys():
		# Find the poses marked "true" - allowed to recognize poses
		if not poses_to_recognize[hand][pose]:
			continue
			
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
