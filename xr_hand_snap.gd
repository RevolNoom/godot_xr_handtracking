extends Marker3D
class_name XRHandSnap

# Used as a reference point to XRPickupFunction
# when it picks up a pick_area

# TODO: Warn when parent is not PickArea

@export var hand: OpenXRHand.Hands = OpenXRHand.Hands.HAND_LEFT
