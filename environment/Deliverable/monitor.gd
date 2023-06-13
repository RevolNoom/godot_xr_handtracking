extends RigidBody3D


@export var cheatcode = "pies"
	

func _on_screen_power_pressed(_key):
	if $Model/Screen.visible:
		$Model/Screen.hide()
	else:
		$Model/Screen/Password.text = ""
		$Model/Screen.show()


func _on_keyboard_power_pressed(_key):
	var enabled = not $KeyboardPower/VRKeyboard.visible
	$KeyboardPower/VRKeyboard.visible = enabled
	$KeyboardPower/VRKeyboard.enabled = enabled


func _on_password_text_submitted(new_text):
	if new_text == cheatcode:
		$PieSpawn.SpawnPies()
