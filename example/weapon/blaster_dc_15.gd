extends XRPickableRigidBody


func _on_pick_area_controller_picked_up(picker: XRPickupFunction, pickarea: XRPickArea):
	super._on_pick_area_controller_picked_up(picker, pickarea)
	picker.connect("pose_updated", _on_hand_pose_updated)


func _on_hand_pose_updated(prev_pose: StringName, current_pose: StringName):
	if current_pose == "Fist"\
			and prev_pose == "One":
		$Barrel.shoot()
	
	
func _on_pick_area_controller_dropped(picker: XRPickupFunction, pickarea: XRPickArea):
	super._on_pick_area_controller_dropped(picker, pickarea)
	picker.disconnect("pose_updated", _on_hand_pose_updated)


