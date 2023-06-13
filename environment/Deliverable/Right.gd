extends XRController3D




func _on_button_pressed(bname):
	if bname == "by_button":
		get_parent().transform = Transform3D(Basis.IDENTITY, Vector3())
