extends RigidBody3D


signal broken(_this_part)

func break_apart():
	freeze = false
	emit_signal("broken", self)
