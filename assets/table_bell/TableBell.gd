extends Node3D

signal pressed
signal unpressed

func _on_area_3d_body_entered(_body):
	if $Button.get_overlapping_bodies().size() == 1:
		$AudioStreamPlayer3D.play()
		emit_signal("pressed")


func _on_area_3d_body_exited(_body):
	if $Button.get_overlapping_bodies().size() == 0:
		emit_signal("unpressed")


func _on_pressed():
	$VRKeyboard.visible = not $VRKeyboard.visible
	$VRKeyboard/Label3D.text = "Text: "
