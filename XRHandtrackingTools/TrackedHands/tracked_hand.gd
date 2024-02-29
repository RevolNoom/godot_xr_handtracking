## Add primitive physics to hand.
##
## Not very interesting. You might want to setup your own hands instead
extends OpenXRHand
class_name XRTrackedHand


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
	hand_collision_layer = hand_collision_layer
	hand_collision_mask = hand_collision_mask


func _process(_delta):
	# Disable processing in editor and on headset
	if Engine.is_editor_hint() or get_viewport().use_xr:
		set_process(false)
	else:
		var pose = ""
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			pose = on_mouse_pressed_pose
		else:
			pose = on_mouse_idle_pose
		assign_pose(pose)


func assign_pose(pose_name: String):
	var hpm = $Skeleton3D/XRPickupFunction/HandPoseMatcher as HandPoseMatcher
	var pose = hpm.pose_catalogue.poses[hand][pose_name] as HandPose
	if pose != null:
		pose.override_skeleton_pose($Skeleton3D)
	
		
		
		
		
		
		
		
		
		
		
		
		
