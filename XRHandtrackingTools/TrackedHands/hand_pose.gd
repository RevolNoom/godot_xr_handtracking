## Resource contains hand bone poses 
## and can override the pose of a [XRTrackedHand],
## or the [Skeleton3D] of a hand.
extends Resource
class_name HandPose

enum Bone{
	WRIST,
	THUMB_METACARPAL,
	THUMB_PROXIMAL,
	THUMB_DISTAL,
	THUMB_TIP,
	INDEX_METACARPAL,
	INDEX_PROXIMAL,
	INDEX_INTERMEDIATE,
	INDEX_DISTAL,
	INDEX_TIP,
	MIDDLE_METACARPAL,
	MIDDLE_PROXIMAL,
	MIDDLE_INTERMEDIATE,
	MIDDLE_DISTAL,
	MIDDLE_TIP,
	RING_METACARPAL,
	RING_PROXIMAL,
	RING_INTERMEDIATE,
	RING_DISTAL,
	RING_TIP,
	LITTLE_METACARPAL,
	LITTLE_PROXIMAL,
	LITTLE_INTERMEDIATE,
	LITTLE_DISTAL,
	LITTLE_TIP,
	PALM,
	MAX_INDEX,
}

@export var name: String = ""
@export var hand: OpenXRHand.Hands = OpenXRHand.HAND_LEFT

## Key - Value: [enum Bone] index - Global [Transform3D] with respect to skeleton.
@export var bone_poses: Dictionary = {
	Bone.WRIST: Transform3D(),
	Bone.THUMB_METACARPAL: Transform3D(),
	Bone.THUMB_PROXIMAL: Transform3D(),
	Bone.THUMB_DISTAL: Transform3D(),
	Bone.THUMB_TIP: Transform3D(),
	Bone.INDEX_METACARPAL: Transform3D(),
	Bone.INDEX_PROXIMAL: Transform3D(),
	Bone.INDEX_INTERMEDIATE: Transform3D(),
	Bone.INDEX_DISTAL: Transform3D(),
	Bone.INDEX_TIP: Transform3D(),
	Bone.MIDDLE_METACARPAL: Transform3D(),
	Bone.MIDDLE_PROXIMAL: Transform3D(),
	Bone.MIDDLE_INTERMEDIATE: Transform3D(),
	Bone.MIDDLE_DISTAL: Transform3D(),
	Bone.MIDDLE_TIP: Transform3D(),
	Bone.RING_METACARPAL: Transform3D(),
	Bone.RING_PROXIMAL: Transform3D(),
	Bone.RING_INTERMEDIATE: Transform3D(),
	Bone.RING_DISTAL: Transform3D(),
	Bone.RING_TIP: Transform3D(),
	Bone.LITTLE_METACARPAL: Transform3D(),
	Bone.LITTLE_PROXIMAL: Transform3D(),
	Bone.LITTLE_INTERMEDIATE: Transform3D(),
	Bone.LITTLE_DISTAL: Transform3D(),
	Bone.LITTLE_TIP: Transform3D(),
	Bone.PALM: Transform3D(),
}


## Override the skeleton pose of this tracked [param hand].
##
## It is assumed that a "Skeleton3D" node is presented.
func override_hand_pose(overridden_hand: XRTrackedHand):
	var hand_skeleton: Skeleton3D = overridden_hand.get_node("Skeleton3D") as Skeleton3D
	if hand_skeleton == null:
		printerr("'Skeleton3D' node not found on hand ", overridden_hand.get_path())
		return
	override_skeleton_pose(hand_skeleton)


## Override the pose of [param skeleton].
##
## [param skeleton] must be a rigged hand skeleton, 
## with 26 bones indexed as [enum Bone]. 
## It also needs to be of corresponding [member hand] to this pose.
func override_skeleton_pose(skeleton: Skeleton3D):
	if skeleton.get_bone_count() != Bone.MAX_INDEX:
		printerr("""Skeleton is not rigged correctly. 
		%d bones are expected but this skeleton has %d bones. 
		The skeleton path is %s.""" % [
			Bone.MAX_INDEX, 
			skeleton.get_bone_count(), 
			skeleton.get_path()])
		return
	
	for idx in range(Bone.MAX_INDEX):
		skeleton.set_bone_global_pose_override(idx, bone_poses[idx], 1.0, true)
		

## Overwrite all the informations from [param hand_pose] to this hand pose.
func copy(hand_pose: HandPose):
	name = hand_pose.name
	hand = hand_pose.hand
	for idx in range(Bone.MAX_INDEX):
		bone_poses[idx] = hand_pose.bone_poses[idx]

		
## Construct a [HandPose] from [param hand].[br]
##
## It is assumed that a "Skeleton3D" node is presented,
## which is a rigged hand with 26 bones indexed as [enum Bone].[br]
## The Skeleton needs to be of corresponding [member hand] to this pose.[br]
##
## Return [constant null] if no "Skeleton3D" node is found.[br]
static func from_hand(copied_hand: XRTrackedHand, pose_name: String) -> HandPose:
	var hand_skeleton: Skeleton3D = copied_hand.get_node("Skeleton3D") as Skeleton3D
	if hand_skeleton == null:
		printerr("'Skeleton3D' node not found on hand ", copied_hand.get_path())
		return null
	return HandPose.from_skeleton(hand_skeleton, pose_name, copied_hand.hand)

## Construct a [HandPose] from [param skeleton].
##
## [param skeleton] must be a rigged hand skeleton, 
## with 26 bones indexed as [enum Bone]. 
## It also needs to be of corresponding [member hand] to this pose.
static func from_skeleton(skeleton: Skeleton3D, pose_name: String, leftness: OpenXRHand.Hands) -> HandPose:
	if skeleton.get_bone_count() != Bone.MAX_INDEX:
		printerr("""Skeleton is not rigged correctly. 
		%d bones are expected but this skeleton has %d bones. 
		The skeleton path is %s.""" % [
			Bone.MAX_INDEX, 
			skeleton.get_bone_count(), 
			skeleton.get_path()])
		return
	
	var hand_pose := HandPose.new()
	hand_pose.name = pose_name
	hand_pose.hand = leftness
	for idx in range(Bone.MAX_INDEX):
		hand_pose.bone_poses[idx] = skeleton.get_bone_global_pose(idx)
	return hand_pose
