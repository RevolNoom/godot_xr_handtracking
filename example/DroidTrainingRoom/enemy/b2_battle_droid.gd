#extends AnimatableBody3D
extends RigidBody3D

signal died(_self)

# Meters per second
@export var speed: float = 0.7

var dead:= false


@onready var _barrels = [
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm/Forearm/Gun/Barrel,
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm/Forearm/Gun/Barrel2
]


func reset_anims():
	$Walking.play("RESET")
	$Aim.play("RESET")


func walk():
	$Walking.play("Walking")


func hold_position():
	$Walking.play("Idle")


func die():
	if dead:
		return
	dead = true
	$Walking.play("Die")
	$Aim.stop()
	$AttackCooldown.stop()
	emit_signal("died", self)
	await get_tree().create_timer(30).timeout
	queue_free()


func attack():
	$Aim.play("Aim")


func _on_heart_body_entered(_body):
	die()


func _on_aim_animation_finished(_anim_name):
	$AttackCooldown.start()


func _on_attack_cooldown_timeout():
	for barrel in _barrels:
		barrel.shoot()
