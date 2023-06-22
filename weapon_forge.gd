extends StaticBody3D

var Weapons := {
	"sung": load("res://blaster_dc_15.tscn"),
	"kiem": load("res://grand_inquisitor_lightsaber.tscn")
}


# Called when the node enters the scene tree for the first time.
func _ready():
	$Table/AnimationPlayer.play("Spin")
	forge_weapon("kiem")


# Create a new weapon if its name is available
func forge_weapon(weapon_name: String):
	if not Weapons.has(weapon_name):
		return
	
	if $Table/Hologram/Spinner/RT.remote_path != NodePath(""):
		var old_weapon = get_node_or_null($Table/Hologram/Spinner/RT.remote_path)
		$Table/Hologram/Spinner/RT.remote_path = NodePath("")
		if old_weapon != null:
			if old_weapon.is_connected("picked", _on_weapon_picked):
				old_weapon.disconnect("picked", _on_weapon_picked)
			old_weapon.freeze = false
	
	var new_weapon = Weapons[weapon_name].instantiate()
	new_weapon.freeze = true
	$WeaponDump.add_child(new_weapon)
	$Table/Hologram/Spinner/RT.remote_path = new_weapon.get_path()
	new_weapon.connect("picked", _on_weapon_picked)


func _on_weapon_picked(weapon: XRPickableRigidBody,\
		_by_hand: XRPickupFunction,\
		_pick_area: XRPickArea):
	weapon.disconnect("picked", _on_weapon_picked)
	$Table/Hologram/Spinner/RT.remote_path = NodePath("")


func _on_timer_timeout():
	var kbs = get_tree().get_nodes_in_group("keyboard")
	for kb in kbs:
		kb.connect("text_submitted", forge_weapon)
