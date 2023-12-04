extends XRPickable


func _on_pick_area_picked_up(picker: XRPickupFunction, pickarea: XRPickArea):
	super._on_pick_area_picked_up(picker, pickarea)
	picker.connect("pose_updated", _on_hand_pose_updated)


func _on_hand_pose_updated(prev_pose: StringName, current_pose: StringName):
	if current_pose == "Fist"\
			and prev_pose == "One":
		$Barrel.shoot()
	
func _on_pick_area_dropped(picker: XRPickupFunction, pickarea: XRPickArea):
	super._on_pick_area_dropped(picker, pickarea)
	picker.disconnect("pose_updated", _on_hand_pose_updated)

func _get_configuration_warnings():
	return super._get_configuration_warnings()
