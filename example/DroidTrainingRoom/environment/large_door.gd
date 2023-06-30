extends Node3D

signal opened(_self)


func open():
	$AnimationPlayer.play("Open")


func close():
	$AnimationPlayer.play_backwards("Open")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Open":
		emit_signal("opened", self)
