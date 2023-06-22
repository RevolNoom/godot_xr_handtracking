extends XRPickableRigidBody

class_name GrandInquisitorLightsaber

@export var max_angular_vel := Vector3(0,0, 4*PI)
@export var min_relock_blades_angular_vel := Vector3(0,0, PI)
@export var torque := Vector3(0,0, 2*PI)

var boomerange_mode_mutex:= Mutex.new()
@export var boomerange_mode := BoomerangeMode.new()


var spinner_angular_vel := Vector3()
var spinning := false


func reset():
	spinning = false
	boomerange_mode.enable = false
	$PickAreaController/Middle.enable_touch_picking = false
	custom_integrator = false

func _on_pick_area_controller_picked_up(by_hand: XRPickupFunction, pick_area: XRPickArea):
	set_boomerange_mode(false)

	spinning = true
	$BladeSound.play()
	
	$Spinner/BladeT/Activate.play("Activate")
	$Spinner/BladeB/Activate.play("Activate")
	super._on_pick_area_controller_picked_up(by_hand, pick_area)


# When a hand drop the saber,
# if it's the movement dictating hand,
# then switch dictation to the remaining one
# If there's no hand left, drop it like usual
func _on_pick_area_controller_dropped(by_hand: XRPickupFunction, pick_area: XRPickArea):
	if $VelocityAverager3D.average_linear_velocity().length() < 0.3:
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
	boomerange_mode_mutex.lock()
	boomerange_mode.enable = enable
	custom_integrator = enable # Process boomerange movement here
	$PickAreaController/Middle.enable_touch_picking = enable
	linear_velocity = Vector3()
	boomerange_mode_mutex.unlock()


func _physics_process(delta: float):
	_process_spin(delta)


func _process_spin(delta: float):
	if spinning:
		spinner_angular_vel += delta * torque
		if spinner_angular_vel.length_squared() >= max_angular_vel.length_squared():
			spinner_angular_vel = max_angular_vel
		if spinner_angular_vel.length_squared() < min_relock_blades_angular_vel.length_squared():
			spinner_angular_vel = min_relock_blades_angular_vel
	elif spinner_angular_vel.length_squared() > min_relock_blades_angular_vel.length_squared():
		spinner_angular_vel -= delta * torque
	
	$BladeSound.pitch_scale = spinner_angular_vel.length() / (2*PI) + 0.001

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
		$BladeSound.stop()
		

# This is where boomerange movement is processed
func _integrate_forces(state):
	boomerange_mode_mutex.lock()
	var bmm = boomerange_mode.enable
	boomerange_mode_mutex.unlock()
	if not bmm:
		return
		
	var come_back_direction = (pick_info.picker.global_transform.origin - global_transform.origin).normalized()
	var come_back_acceleration = state.step * come_back_direction * boomerange_mode.pull_back_force
	
	state.linear_velocity += come_back_acceleration
	if state.linear_velocity.angle_to(come_back_direction) < PI/2.1:
		state.linear_velocity = come_back_direction.normalized()\
				* min(state.linear_velocity.length(),\
				boomerange_mode.max_linear_velocity)
	state.angular_velocity = Vector3()


func _on_blade_body_entered(body):
	# This is probably BattleDroid's Body node
	# Get that droid and kill it
	if body is RigidBody3D:
		var droid = body.get_parent().get_parent()
		body.freeze = false
		droid.die()


func _on_touch_pick_enabled_timeout():
	print("Time out")
	$PickAreaController/Middle.enable_touch_picking = false
