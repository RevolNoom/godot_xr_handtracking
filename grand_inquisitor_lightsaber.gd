extends XRPickableRigidBody

class_name GrandInquisitorLightsaber

@export var max_angular_vel := Vector3(0,0, 7*PI)
@export var min_relock_blades_angular_vel := Vector3(0,0, PI/2)
@export var torque := Vector3(0,0, 3*PI)

@export var boomerange_mode := BoomerangeMode.new()


var spinner_angular_vel := Vector3()
var spinning := false


func _on_pick_area_controller_picked_up(by_hand: XRPickupFunction, pick_area: XRPickArea):
	set_boomerange_mode(false)

	spinning = true
	
	$Spinner/BladeT/Activate.play("Activate")
	$Spinner/BladeB/Activate.play("Activate")
	super._on_pick_area_controller_picked_up(by_hand, pick_area)


# When a hand drop the saber,
# if it's the movement dictating hand,
# then switch dictation to the remaining one
# If there's no hand left, drop it like usual
func _on_pick_area_controller_dropped(by_hand: XRPickupFunction, pick_area: XRPickArea):
	if $VelocityAverager3D.average_linear_velocity().length() < 0.5:
		spinning = false
		$Spinner/BladeT/Activate.play_backwards("Activate")
		$Spinner/BladeB/Activate.play_backwards("Activate")
		super._on_pick_area_controller_dropped(by_hand, pick_area)
		return
		
	else:
		freeze = false
		set_boomerange_mode(true)
		by_hand.disconnect("transform_updated", _on_hand_transform_updated)
		collision_mask = original_collision_mask
		collision_layer = original_collision_layer
		
		linear_velocity = $VelocityAverager3D.average_linear_velocity()\
				* boomerange_mode.hand_leaving_multiplier
		emit_signal("dropped", self, by_hand, pick_area)


func set_boomerange_mode(enable: bool):
	boomerange_mode.enable = true
	custom_integrator = enable # Process boomerange movement here
	$Handle/PickAreaController/Middle.pick_on_touch = enable
	if enable:
		$Handle/PickAreaController/Middle.pickup_poses\
			.append_array(boomerange_mode.touch_grab_poses)
	else:
		for pose in boomerange_mode.touch_grab_poses:
			var id = $Handle/PickAreaController/Middle.pickup_poses.find(pose)
			if id != -1:
				$Handle/PickAreaController/Middle.pickup_poses.remove_at(id)
	


func _physics_process(delta):
	if spinning:
		spinner_angular_vel += delta * torque
		if spinner_angular_vel.length_squared() >= max_angular_vel.length_squared():
			spinner_angular_vel = max_angular_vel
	elif spinner_angular_vel.length_squared() > min_relock_blades_angular_vel.length_squared():
		spinner_angular_vel -= delta * torque

	var rotz_before_spin = $Spinner.rotation.z
	$Spinner.rotation = $Spinner.rotation + spinner_angular_vel * delta
	$Spinner.rotation.x = fmod($Spinner.rotation.x, 2*PI)
	$Spinner.rotation.y = fmod($Spinner.rotation.y, 2*PI)
	$Spinner.rotation.z = fmod($Spinner.rotation.z, 2*PI)
	var rotz_after_spin = $Spinner.rotation.z
	
	# Stop condition
	if not spinning\
			and spinner_angular_vel < min_relock_blades_angular_vel\
			and PI <= rotz_before_spin and rotz_before_spin < 2*PI\
			and 0 <= rotz_after_spin and rotz_after_spin < PI:
		$Spinner.rotation =  Vector3()
		spinner_angular_vel = Vector3()
		

# This is where boomerange movement is processed
func _integrate_forces(state):
	if not boomerange_mode.enable:
		return
	var come_back_direction = (pick_info.picker.global_transform.origin - state.transform.origin).normalized()
	var come_back_acceleration = state.step * come_back_direction * boomerange_mode.pull_back_force
	
	state.linear_velocity +=come_back_acceleration	
	state.angular_velocity = Vector3()
