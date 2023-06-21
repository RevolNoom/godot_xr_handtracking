#extends AnimatableBody3D
extends RigidBody3D

signal died(_self)

# Meters per second
@export var speed: float = 0.7


@onready var _barrels = [
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm/Forearm/Gun/Barrel,
	$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm/Forearm/Gun/Barrel2
]

#func _ready():
	#die()
	

func walk():
	$Walking.play("Walking")


func hold_position():
	$Walking.play("Idle")


func attack():
	$Aim.play("Aim")


func die():
	$Walking.play("Die")
	$AttackCooldown.stop()
	emit_signal("died", self)
	
	
func _on_heart_body_entered(_body):
	die()


func _on_aim_animation_finished(_anim_name):
	$AttackCooldown.start()


func _on_attack_cooldown_timeout():
	for barrel in _barrels:
		barrel.shoot()


func _on_body_body_entered(body):
	if body is GrandInquisitorLightsaber:
		die()
