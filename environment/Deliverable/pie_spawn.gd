extends Node3D


@export var y_angular_velocity = PI/6


var Pies = [
	load("res://assets/pies/pies_type/berry_pie.tscn"),
	load("res://assets/pies/pies_type/coco_pie.tscn"),
	load("res://assets/pies/pies_type/leaf_pie.tscn"),
	load("res://assets/pies/pies_type/mousse.tscn"),
	load("res://assets/pies/pies_type/raspberry_pie.tscn"),
	load("res://assets/pies/pies_type/vanilla_pie.tscn")]


func _process(delta):
	$Spin.rotate_y(delta*y_angular_velocity)


func spawn_pies():
	if $Spin/Pie1.get_child_count() > 0:
		_dump_pies()
	var new_pies = []
	for pie in Pies:
		new_pies.push_back(pie.instantiate())
		new_pies.back().freeze = true
	
	for slot in $Spin.get_children():
		var pie = new_pies.pop_back()
		slot.add_child(pie)
		pie.connect("picked", _on_pie_picked)


func _dump_pies():
	for slot in $Spin.get_children():
		if slot.get_child_count() == 0:
			continue
		for pie in slot.get_children():
			var transf = pie.global_transform
			slot.remove_child(pie)
			$Dump.add_child(pie)
			pie.global_transform = transf
			pie.freeze = false
			pie.disconnect("picked", _on_pie_picked)


func _on_pie_picked(_pie: Node3D, _by_hand: XRPickupFunction, _pick_area: XRPickArea):
	_dump_pies()
