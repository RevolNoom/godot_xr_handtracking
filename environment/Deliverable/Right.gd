extends XRController3D




func _on_button_pressed(bname):
	if bname == "by_button":
		print("Pressed 'by'")
		var origin = get_parent().get_parent()
		var camera = get_parent().get_node("XRCamera3D")
		var offsetting = origin.global_position - camera.global_position
		offsetting.y = 0
		get_parent().global_position += offsetting
		
