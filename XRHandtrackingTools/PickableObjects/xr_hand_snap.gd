extends Marker3D
class_name XRHandSnap

# XRHandSnap represents the position and rotation
# of XRPickupFunction when it picks up.
# (how the hand would look respectively to the object)
# You have to experiment around to find the best snap spots
#
# Adding XRHandSnap to object doesn't mean the object 
# would magically snap to hand. You, the coder, decides whether
# you would want to snap to hand in your object's script.
# To do that, call XRPickArea.get_hand_snap()
# 
# Snapping behavior is already implemented in XRPickable


@export var hand: OpenXRHand.Hands = OpenXRHand.Hands.HAND_LEFT


func _enter_tree():
	update_configuration_warnings()

func _ready():
	update_configuration_warnings()
	

func _get_configuration_warnings():
	if get_parent() and get_parent() is XRPickArea:
		return []
	return "This node should be child of XRPickArea."
