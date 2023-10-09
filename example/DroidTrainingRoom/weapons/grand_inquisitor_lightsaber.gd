extends XRPickableRigidBody

class_name GrandInquisitorLightsaber

@export var max_angular_vel := Vector3(0,0, 4*PI)
@export var min_spin_angular_vel := Vector3(0,0, PI)
@export var torque := Vector3(0,0, 2*PI)


@export var boomerange_mode := BoomerangeMode.new()


var _spinner_angular_vel := Vector3()
var _spinning := false
var _boomerange_thrower = null


func reset():
	freeze = false
	_spinning = false
	boomerange_mode.enable = false
	$PickAreaController/Handle.enable_touch_picking = false
	custom_integrator = false
	if $Spinner/BladeT.scale != Vector3(1,0,1):
		$Spinner/BladeT/Activate.play_backwards("Activate")
		$Spinner/BladeB/Activate.play_backwards("Activate")


func _on_pick_area_controller_picked_up(picker: XRPickupFunction, pick_area: XRPickArea):
	set_boomerange_mode(false)
	_spinning = true
	$BladeSound.play()
	
	$Spinner/BladeT/Activate.play("Activate")
	$Spinner/BladeB/Activate.play("Activate")
	super._on_pick_area_controller_picked_up(picker, pick_area)


# When a hand drop the saber,
# if it's the movement dictating hand,
# then switch dictation to the remaining one
# If there's no hand left, drop it like usual
func _on_pick_area_controller_dropped(picker: XRPickupFunction, pick_area: XRPickArea):
	if picker.get_linear_velocity().length() < 0.2:
		_spinning = false
		$Spinner/BladeT/Activate.play_backwards("Activate")
		$Spinner/BladeB/Activate.play_backwards("Activate")
		super._on_pick_area_controller_dropped(picker, pick_area)
	else:
		_boomerange_thrower = picker
		set_boomerange_mode(true)
		super._on_pick_area_controller_dropped(picker, pick_area)
		linear_velocity = picker.get_linear_velocity()\
				* boomerange_mode.hand_leaving_multiplier


func set_boomerange_mode(enable: bool):
	boomerange_mode.enable = enable
	custom_integrator = enable # Process boomerange movement here
	$PickAreaController/Handle.enable_touch_picking = enable
	linear_velocity = Vector3()


func _physics_process(delta: float):
	_process_spin(delta)


func _process_spin(delta: float):
	var savls = _spinner_angular_vel.length_squared()
	if _spinning:
		_spinner_angular_vel += delta * torque
		if savls >= max_angular_vel.length_squared():
			_spinner_angular_vel = max_angular_vel
		if savls < min_spin_angular_vel.length_squared():
			_spinner_angular_vel = min_spin_angular_vel
	elif savls > min_spin_angular_vel.length_squared():
		_spinner_angular_vel -= delta * torque
	
	$BladeSound.pitch_scale = _spinner_angular_vel.length() / (2*PI) + 0.001

	var rotz_before_spin = $Spinner.rotation.z
	$Spinner.rotation = $Spinner.rotation + _spinner_angular_vel * delta
	$Spinner.rotation.x = fmod($Spinner.rotation.x, 2*PI)
	$Spinner.rotation.y = fmod($Spinner.rotation.y, 2*PI)
	$Spinner.rotation.z = fmod($Spinner.rotation.z, 2*PI)
	var rotz_after_spin = $Spinner.rotation.z
	
	# Stop condition
	if not _spinning\
			and _spinner_angular_vel < min_spin_angular_vel\
			and PI <= rotz_before_spin and rotz_before_spin < 2*PI\
			and 0 <= rotz_after_spin and rotz_after_spin < PI:
		$Spinner.rotation =  Vector3()
		_spinner_angular_vel = Vector3()
		$BladeSound.stop()
		

# This is where boomerange movement is processed
func _integrate_forces(state):
	if not boomerange_mode.enable:
		return
		
	var come_back_direction = (_boomerange_thrower.global_transform.origin - global_transform.origin).normalized()
	var come_back_acceleration = state.step * come_back_direction * boomerange_mode.pull_back_force
	
	state.linear_velocity += come_back_acceleration
	if state.linear_velocity.angle_to(come_back_direction) < PI/3:
		state.linear_velocity = come_back_direction.normalized()\
				* min(state.linear_velocity.length(),\
				boomerange_mode.max_linear_velocity)
	state.angular_velocity = Vector3()


func _on_blade_body_entered(body):
	# This is probably BattleDroid's Body node
	# Get that droid and kill it
	if body is RigidBody3D:
		var droid = body.get_parent().get_parent()
		droid.die()
