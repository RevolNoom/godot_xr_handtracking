extends XRController3D

# This node helps resetting the playing position back to default.
# Sometimes my Oculus would put me somewhere far away
# from where I put my XROrigin. It happens when I reset Guardian.


func _on_button_pressed(bname):
	if bname == "by_button":
		print("Pressed 'by'")
		_reset_xrorigin_to_default()


# Mirroring x, z position
func _reset_xrorigin_to_default():
		var origin = get_parent().get_parent()
		var camera = get_parent().get_node("XRCamera3D")
		var offsetting = origin.global_position - camera.global_position
		offsetting.y = 0
		get_parent().global_position += offsetting


func _on_timer_timeout():
	_reset_xrorigin_to_default()
