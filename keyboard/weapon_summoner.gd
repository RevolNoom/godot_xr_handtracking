extends Node3D

signal weapon_summoned(weapon_name: String)

func _on_power_pressed(_key):
	$Keys.show()
	for key in $Keys.get_children():
		key.enabled = true


func _on_power_unpressed(_key):
	_turn_off_keys()


func _turn_off_keys():
	$Keys.hide()
	for key in $Keys.get_children():
		key.enabled = false
	

func _on_blaster_pressed(_key):
	_turn_off_keys()
	emit_signal("weapon_summoned", "sung")


func _on_lightsaber_pressed(_key):
	_turn_off_keys()
	emit_signal("weapon_summoned", "kiem")
