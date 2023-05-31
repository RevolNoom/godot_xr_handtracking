extends Marker3D


signal transformed(global_movement: Vector3, global_orthonormalized_rotation: Basis)

@onready var prev_base_gpos: Vector3 = $Base.global_position
@onready var prev_base_grot: Basis = $Base.global_transform.basis
var func_pick_up: XRHandFunctionPickup

@onready var initial_base_transform: Transform3D = $Base.transform
var enable_signalling: bool = false


func _on_grab_point_controller_picked_up(by_hand: XRHandFunctionPickup, _at_grab_point):
	func_pick_up = by_hand
	func_pick_up.connect("hand_pose_updated", _on_hand_pose_updated)
	$Base/AnimatedSprite3D.show()
	$Base/AnimatedSprite3D.play("load")


func _on_hand_pose_updated():
	$Base.global_rotation = func_pick_up.global_rotation
	$Base.global_position = func_pick_up.global_position
	
	var orthonormalized_base_basis = $Base.global_transform.basis.orthonormalized()
	var gmovement = $Base.global_position - prev_base_gpos
	var grotation = orthonormalized_base_basis\
				* prev_base_grot.orthonormalized().inverse()
	
	prev_base_gpos = $Base.global_position
	prev_base_grot = $Base.global_transform.basis

	if enable_signalling:
		emit_signal("transformed", gmovement, grotation)


func _on_animated_sprite_3d_animation_finished():
	$Base/AnimatedSprite3D.hide()
	enable_signalling = true
	
	
func _on_grab_point_controller_dropped(by_hand: XRHandFunctionPickup):
	by_hand.disconnect("hand_pose_updated", _on_hand_pose_updated)
	$Base/AnimatedSprite3D.hide()
	enable_signalling = false
	$Base/GrabPointController.enabled = false
	var tween = create_tween().tween_property($Base, "transform", initial_base_transform, 1)
	tween.set_trans(Tween.TRANS_BACK)
	tween.connect("finished", _on_tween_finished)


func _on_tween_finished():
	$Base/GrabPointController.enabled = true


