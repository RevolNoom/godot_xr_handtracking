@tool
extends Node3D

class_name XRPickAreaController

signal picked_up(by_hand: Skeleton3D, pick_point: XRPickArea)
signal dropped(by_hand)

# Amount of grab points that can be grabbed simultaneously
# NOTE: It currently doesn't support more than 1 grab
@export_range(0, 999) var max_grabbable: int = 1
var _pick_points: Array[XRPickArea] = []
var _current_grabbers: Array = []

## If true, the pickable supports being picked up
@export var enabled : bool = true

func _enter_tree():
	update_configuration_warnings()
	
func _ready():
	update_configuration_warnings()


func get_object():
	return get_parent()


# Test if this object can be picked up
func can_pick_up() -> bool:
	#print("Controller can pick up? : " + str(enabled and _current_grabbers.size() < max_grabbable))
	return enabled and _current_grabbers.size() < max_grabbable


# Called when this object is picked up
func _on_grabpoint_pick_up(by_hand: Node3D, pickpoint: XRPickArea) -> void:
	# Skip if disabled or already picked up
	if not can_pick_up():
		return

	_current_grabbers.push_back(by_hand)
	emit_signal("picked_up", by_hand, pickpoint)


func GetPickPoints() -> Array:
	var result = []
	for child in get_children():
		if child is XRPickArea:
			result.push_back(child)
	return result


# Called when this object is dropped
func let_go(by_hand):
	_current_grabbers.erase(by_hand)
	# let interested parties know
	emit_signal("dropped", by_hand)


func _on_child_entered_tree(node):
	if node is XRPickArea:
		_pick_points.append(node)
	update_configuration_warnings()


func _on_child_exiting_tree(node):
	if node is XRPickArea:
		_pick_points.erase(node)
	update_configuration_warnings()


func _get_configuration_warnings():
	var warnings: PackedStringArray = []
	if not get_parent() is Node3D:
		warnings.append("This node must be child of a Node3D object.")
	for child in get_children():
		if child is XRPickArea:
			return warnings
	warnings.append("Please add some children XRPickArea.")
	return warnings

