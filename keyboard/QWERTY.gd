extends Node3D

signal pressed(keycode)
signal unpressed(keycode)


@export var enabled: bool = true:
	set(enable):
		enabled = enable
		if pfls.size() > 0:
			for pfl in pfls:
				var key = pfl.get_child(0)
				key.enabled = enable


@onready var pfls: Array = $RowNumber.get_children() + $Row1.get_children()\
				+ $Row2.get_children() + $Row3.get_children()\
				+ [$Space]


func _ready():
	# Trigger "enabled" setter
	enabled = enabled
	for pfl in pfls:
		var key = pfl.get_child(0)
		key.connect("pressed", _on_key_pressed)
		key.connect("unpressed", _on_key_unpressed)


func _on_key_pressed(key):
	emit_signal("pressed", key)


func _on_key_unpressed(key):
	emit_signal("unpressed", key)


func _on_set_transform_remote_transformed(global_movement, global_orthonormalized_rotation):
	global_transform.basis = global_orthonormalized_rotation * global_transform.basis
	global_position += global_movement
