extends Marker3D

# Shoot a bullet in local x-direction
@export var Bullet: PackedScene = preload("res://example/weapon/lazer_bullet.tscn")
@export var x_axis_impulse = 60
	
	
func shoot():
	$ShootAudio.play()
	var b = Bullet.instantiate()
	$Dump.add_child(b)
	b.global_position = global_position
	b.global_rotation = global_rotation
	
	var shoot_direction = global_transform.basis.x.normalized()
	b.apply_central_impulse(shoot_direction * x_axis_impulse)
