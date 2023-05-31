extends Node3D

signal pressed(keycode)

func _ready():
	var pfls = $Row1.get_children() + $Row2.get_children() + $Row3.get_children()
	for pfl in pfls:
		var key = pfl.get_child(0)
		key.connect("pressed", _on_key_pressed)
		
		
func _on_key_pressed(key):
	emit_signal("pressed", key)


func _on_setting_pos_rot_transformed(global_movement, global_orthonormalized_rotation):
	global_transform.basis = global_orthonormalized_rotation * global_transform.basis
	global_position += global_movement
