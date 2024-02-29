@tool

## Put your hand inside this area to get information about 
## position, rotation of each hand bone
##
## Note: Change the displayed pose name by changing the node's name
extends Area3D
class_name HandPoseCaptureArea

## Emitted when a hand has been in the area after the timer timed out.
signal recorded(pose: HandPose)


func _ready():
	$PoseName.text = name


## Modify the little hand models 
## So that you can do an after check to see that they are correctly recorded.
func apply_pose_on_hand(hand: Skeleton3D, pose: HandPose):
	pose.override_skeleton_pose(hand)


func get_hand(hand: OpenXRHand.Hands) -> Skeleton3D:
	return $Hands/left if hand == OpenXRHand.HAND_LEFT else $Hands/right

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
	
	var pose = HandPose.from_hand(openxr_hand, $PoseName.text)
	apply_pose_on_hand(get_hand(openxr_hand.hand), pose)
	recorded.emit(pose)


func _on_property_list_changed():
	$PoseName.text = name

