extends XROrigin3D

func _on_vr_keyboard_pressed(key: String):
	$Label3D.text = $Label3D.text + key
	pass # Replace with function body.
