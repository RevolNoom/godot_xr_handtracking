extends OpenXRHand
class_name XRTrackedHand


# This class contains my attempt to add physics to my hands
# so that they can press buttons on my keyboard
#
# Not very interesting. You might want to setup your own hands.



@export_flags_3d_physics var hand_collision_layer: int = 0b00000000_00000010_00000000_00000000:
	set(value):
		if get_child_count() == 0:
			return
		hand_collision_layer = value
		for bone in $Skeleton3D.get_children():
			if bone is BoneAttachment3D:
				var physic_body = bone.get_child(0)
				if physic_body is CharacterBody3D:
					physic_body.collision_layer = hand_collision_layer


@export_flags_3d_physics var hand_collision_mask : int = 0b00000000_00000000_00000000_00000111:
	set(value):
		if get_child_count() == 0:
			return
		hand_collision_mask = value
		for bone in $Skeleton3D.get_children():
			if bone is BoneAttachment3D:
				var physic_body = bone.get_child(0)
				if physic_body is CharacterBody3D:
					physic_body.collision_mask = hand_collision_mask


func _ready():
	hand_collision_layer = hand_collision_layer
	hand_collision_mask = hand_collision_mask
