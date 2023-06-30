@tool
extends Node3D
class_name XRPickAreaController


# Controls a group of XRPickArea.
#
# You connect the picked_up and dropped signal to the interested party
# and when a hand picks one of its child XRPickArea, it will tell you
#
# You decide how the object will move, corresponding to hand movement.
# Some example movement codes are in XRPickableRigidBody.
#
# Modify simultaneous_pick if an object 
# has two or more places that can be picked by both hand
#
# Modify enabled to stop the object from being picked.
#
# Modifying either of these exported var doesn't make the object
# suddenly drops out of grabbing hand


signal picked_up(picker: XRPickupFunction, pickarea: XRPickArea)
signal ranged_picked_up(picker: XRPickupFunction, pickarea: XRPickArea)
signal dropped(picker: XRPickupFunction, pickarea: XRPickArea)


# Amount of XRPickArea that can be picked simultaneously
@export_range(0, 999) var simultaneous_pick: int = 1
# Allow children XRPickArea to be picked if true
@export var enabled : bool = true
# The object this controller is attached to
# XRPickupFunction will want to know what object it has
# picked up via a XRPickArea.
# Child XRPickArea will ask this node, and this node will
# supply the answer
# Default to parent node
@export_node_path() var attached_to_object


var _pickareas: Array[XRPickArea] = []
var _current_pickers: Array = []



func _enter_tree():
	update_configuration_warnings()


func _ready():
	update_configuration_warnings()


func get_object() -> Node:
	return get_node(attached_to_object)


# Test if this object can be picked up
func can_pick_up() -> bool:
	return enabled and _current_pickers.size() < simultaneous_pick


# Called when this object is picked up
func _on_pickarea_picked_up(picker: XRPickupFunction, pickarea: XRPickArea) -> void:
	# Skip if disabled or already picked up
	if not can_pick_up():
		return

	_current_pickers.push_back(picker)
	emit_signal("picked_up", picker, pickarea)


# Called when this object is ranged-picked
func _on_pickarea_ranged_picked_up(picker: XRPickupFunction, pickarea: XRPickArea) -> void:
	# Skip if disabled or already picked up
	if not can_pick_up():
		return
	_current_pickers.push_back(picker)
	emit_signal("ranged_picked_up", picker, pickarea)


func get_pickareas() -> Array[XRPickArea]:
	var result: Array[XRPickArea] = []
	for child in get_children():
		if child is XRPickArea:
			result.push_back(child)
	return result


# Called when this object is dropped
func let_go(picker: XRPickupFunction, pickarea: XRPickArea):
	_current_pickers.erase(picker)
	# let interested parties know
	emit_signal("dropped", picker, pickarea)


func _on_child_entered_tree(node):
	if node is XRPickArea:
		_pickareas.append(node)
	update_configuration_warnings()


func _on_child_exiting_tree(node):
	if node is XRPickArea:
		_pickareas.erase(node)
	update_configuration_warnings()


func _get_configuration_warnings():
	var warnings: PackedStringArray = []
	if attached_to_object == NodePath():
		warnings.append("Please set the object that PickAreaController attaches to.\n\
				XRPickupFunction needs to know what object it has picked up.")
		
	for child in get_children():
		if child is XRPickArea:
			return warnings
			
		
	warnings.append("Please add some children XRPickArea.")
	return warnings

