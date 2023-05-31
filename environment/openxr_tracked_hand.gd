extends OpenXRHand

@export_flags_3d_physics var hand_collision_layer: int = 0b00000000_00000001_00000000_00000000:
	set(value):
		if get_child_count() == 0:
			return
		hand_collision_layer = value
		for bone in $Skeleton3D.get_children():
			if bone is BoneAttachment3D:
				bone.get_node("Body").collision_layer = hand_collision_layer
		


@export_flags_3d_physics var hand_collision_mask : int = 0b00000000_00000000_00000000_00000111:
	set(value):
		if get_child_count() == 0:
			return
		hand_collision_mask = value
		for bone in $Skeleton3D.get_children():
			if bone is BoneAttachment3D:
				bone.get_node("Body").collision_mask = hand_collision_mask


func _ready():
	hand_collision_layer = hand_collision_layer
	hand_collision_mask = hand_collision_mask

