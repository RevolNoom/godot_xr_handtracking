@tool
extends Node3D
class_name XRPickAreaController

## Amount of XRPickArea that can be picked up simultaneously
@export_range(0, 99999) var simultaneous_pick: int = 1
## If true, allow children XRPickArea to be picked
## If false, disable children XRPickArea from being picked
@export var enabled : bool = true

var _pickareas: Array[XRPickArea] = []
var _current_pickers: Array = []

func _enter_tree():
	update_configuration_warnings()


func _ready():
	update_configuration_warnings()


## Return the XRPickable this XRPickAreaController attaches to
func get_object() -> XRPickable:
	return get_parent()


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
	if get_object() is:
		warnings.append("Please set the object that PickAreaController attaches to.\n\
				XRPickupFunction needs to know what object it has picked up.")

	if simultaneous_pick > 1:
		warnings.append("Remember to implement dual-hand object movement. You may comment out this warning")
	for child in get_children():
		if child is XRPickArea:
			return warnings
			
		
	warnings.append("Please add some children XRPickArea.")
	return warnings

