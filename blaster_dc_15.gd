extends XRPickableRigidBody

	

func _on_pick_area_controller_picked_up(by_hand: XRPickupFunction, pick_point: XRPickArea):
	super._on_pick_area_controller_picked_up(by_hand, pick_point)
	by_hand.connect("pose_updated", _on_hand_pose_updated)


func _on_hand_pose_updated(prev_pose: StringName, current_pose: StringName):
	if current_pose in ["Grip", "Fist"]\
			and prev_pose not in ["Grip", "Fist"]:
		$Barrel.shoot()
	
	
func _on_pick_area_controller_dropped(by_hand: XRPickupFunction, pick_point: XRPickArea):
	super._on_pick_area_controller_dropped(by_hand, pick_point)
	by_hand.disconnect("pose_updated", _on_hand_pose_updated)
