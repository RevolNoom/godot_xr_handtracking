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

@onready var breakable_parts = [
	$Hip/Body,
	$Hip/ThighLeft,
	$Hip/ThighRight,
	$Hip/ThighLeft/ThighLeft/Knee/Shin,
	$Hip/ThighRight/ThighRight/Knee/Shin,
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight,
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperarmLeft,
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperarmLeft/UpperarmLeft/Elbow/Forearm,
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm
]


func _ready():
	for part in breakable_parts:
		part.connect("broken", _on_part_broken)


func _on_part_broken(part):
	if part in [
		$Hip/Body,
		$Hip/ThighLeft,
		$Hip/ThighRight,
		$Hip/ThighLeft/ThighLeft/Knee/Shin,
		$Hip/ThighRight/ThighRight/Knee/Shin,
	]:
		die()


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
	$AttackCooldown.stop()
	emit_signal("died", self)


func attack():
	$Aim.play("Aim")


func _on_heart_body_entered(_body):
	die()


func _on_aim_animation_finished(_anim_name):
	$AttackCooldown.start()


func _on_attack_cooldown_timeout():
	for barrel in _barrels:
		barrel.shoot()
