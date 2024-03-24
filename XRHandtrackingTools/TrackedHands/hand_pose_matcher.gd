@tool
## Match a hand pose to its corresponding pose name. 
##
## This class compares the bones transforms of a hand
## to [HandPose]s from [HandPoseCatalogue] in every frame.[br]
##
## [b]NOTE:[/b] If it doesn't match anything, make sure you have given 
## hand_pose_templates a valid json
extends Node
class_name HandPoseMatcher


## Emitted when the [member skeleton] changes its pose.
signal new_pose(previous_pose: StringName, pose: StringName)

@export var hand: OpenXRHand.Hands = OpenXRHand.HAND_LEFT

## The Skeleton3D that needs its pose identified.[br]
##
## The following hierachy is assumed:[br]
## OpenXRHand - Skeleton3D - XRPickupFunction - HandPoseMatcher[br]
##
## [b]NOTE:[/b] This property is already assigned by [XRPickupFunction] on _ready()
## Modify that if you have other needs.[br]
@export var skeleton: Skeleton3D = null:
	set(skel):
		skeleton = skel
		set_process(pose_catalogue != null\
				and skeleton != null\
				and not Engine.is_editor_hint())


## Prevent jittering recognition between two poses 
## by adding a stable zone to pose difference calculation.[br]
##
## Disable stabilization by setting a huge number to it ([constant INF], for example).[br]
@export var pose_stabilizer: float = 0.005


## The list of [HandPose]s to compare to.
@export var pose_catalogue: HandPoseCatalogue:
	set(value):
		pose_catalogue = value
		poses_to_recognize = {}
		for pose in pose_catalogue.poses[hand].keys():
			poses_to_recognize[pose] = true
		

## Poses from supported_poses that's allowed to be recognized.[br]
## Disable poses you don't want to recognize to improve accuracy and performance.[br]
##
## Key - Value: Pose name (String) - Enabled (bool)[br]
@export var poses_to_recognize:= {}


var current_pose: StringName = ""
var previous_pose: StringName = ""


func _ready():
	set_process(pose_catalogue != null\
			and skeleton != null\
			and not Engine.is_editor_hint())


func _find_pose_most_similar_to_current_skeleton() -> StringName:
	var best_match_pose: StringName
	var best_difference: float = INF
	var current_skeleton_pose = HandPose.from_skeleton(skeleton, "", hand)
	
	var difference_to_current_pose = INF
	if pose_catalogue.poses[hand].has(current_pose):
		best_match_pose = current_pose
		difference_to_current_pose = HandPoseMatcher.calculate_difference(
					current_skeleton_pose, 
					pose_catalogue.poses[hand][current_pose]) - pose_stabilizer
		
	for pose in poses_to_recognize.keys():
		if not poses_to_recognize[pose]:
			continue
			
		var difference = HandPoseMatcher.calculate_difference(
				current_skeleton_pose, pose_catalogue.poses[hand][pose])
		
		if difference < best_difference and difference < difference_to_current_pose:
			best_match_pose = pose
			best_difference = difference
	
	return best_match_pose


## Calculate the difference between 2 poses 
static func calculate_difference(pose1: HandPose, pose2: HandPose) -> float:
	var difference = 0.0
	for bone in pose1.bone_poses.keys():
		var bone1 := pose1.bone_poses[bone] as Transform3D
		var bone2 := pose2.bone_poses[bone] as Transform3D
		var pos_diff = bone2.origin.distance_to(bone1.origin)
		var rot_diff = (Quaternion(bone2.basis)*(Quaternion(bone1.basis).inverse())).get_angle()
		difference += abs(pos_diff * rot_diff + pos_diff + rot_diff)
	return difference


func _process(_delta):
	var recognized_pose: StringName = _find_pose_most_similar_to_current_skeleton()
	if recognized_pose != current_pose:
		previous_pose = current_pose
		current_pose = recognized_pose
		emit_signal("new_pose", previous_pose, recognized_pose)
