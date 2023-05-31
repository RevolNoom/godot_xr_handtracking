extends CharacterBody3D

signal picked(_self)
signal dropped(_self)


func _on_grab_point_controller_picked_up():
	emit_signal("picked", self)


func _on_grab_point_controller_dropped():
	emit_signal("dropped", self)
