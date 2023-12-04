extends OpenXRHand
class_name XRTrackedHand


# This class contains my attempt to add physics to hands
# so that they can press keyboard buttons
#
# Not very interesting. You might want to setup your own hands instead

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


## Debug. The pose to enforce on the skeleton when press left mouse
@export var on_mouse_pressed_pose: String = "Fist"

## Debug. The pose to enforce on the skeleton when left mouse is unpressed
@export var on_mouse_idle_pose: String = "Rest"

func _ready():
	if Engine.is_editor_hint():
		set_process(false)
	hand_collision_layer = hand_collision_layer
	hand_collision_mask = hand_collision_mask


func _process(_delta):
	var pose = ""
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pose = on_mouse_pressed_pose
	else:
		pose = on_mouse_idle_pose
	assign_pose(pose)

## @pose_name is one of the poses_to_recognize pose name
func assign_pose(pose_name: String):
	var hpm = $Skeleton3D/XRPickupFunction/HandPoseMatcher
	var pose_bones = hpm.supported_poses[hpm.hand][pose_name]
	for i in range($Skeleton3D.get_bone_count()):
		var bone_gpos: Vector3 = pose_bones[str(i)][HandPoseMatcher.POSITION]
		var bone_grot: Quaternion = pose_bones[str(i)][HandPoseMatcher.ROTATION]
		#$Skeleton3D.set_bone_global_pose_override(i, Transform3D(Basis(bone_grot), bone_gpos), 1, true)
		$Skeleton3D.set_bone_pose_rotation(i, bone_grot)
		
		
		
		
		
		
		
		
		
		
		
		
