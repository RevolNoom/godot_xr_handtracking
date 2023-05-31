extends Node3D


signal pressed(key: String)


func _on_qwerty_pressed(keycode):
	emit_signal("pressed", keycode)


func _on_settings_pressed(key):
	pass # Replace with function body.
