extends Resource
class_name HandPoseCatalogue

signal updated

## Dictionary<Handedness, Dictionary<Pose name (String), [HandPose]>>
@export var poses: Dictionary = {
	OpenXRHand.HAND_LEFT: {},
	OpenXRHand.HAND_RIGHT: {},
}

## Return true if the [param pose] was added successfully.
func add(pose: HandPose) -> bool:
	if not poses.has(pose.hand):
		return false
	poses[pose.hand][pose.name] = pose
	updated.emit()
	return true


## Return true if the [param pose] was removed successfully from the template
func remove(pose: HandPose) -> bool:
	return remove_pose(pose.name, pose.hand)


## Return true if the [param pose_name] on [param hand] was removed successfully.
func remove_pose(pose_name: String, hand: OpenXRHand.Hands) -> bool:
	if not poses.has(hand):
		return false
	var erased = (poses[hand] as Dictionary).erase(pose_name)
	updated.emit()
	return erased


## Return the [HandPose] with [param name] on [param hand]. 
## Or [constant null] if it doesn't exist.
func get_pose(name: String, hand: OpenXRHand.Hands) -> HandPose:
	return (poses.get(hand, {}) as Dictionary).get(name)
	
