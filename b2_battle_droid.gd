extends AnimatableBody3D


signal die(_self)

@export var speed: float = 1


@onready var _barrels = [
		$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm/Forearm/Gun/Barrel,
		$Hip/Body/Groin/Torso/Ribs/LowerChest/Chest/Head/Shoulders/UpperArmRight/UpperArmRight/Elbow/Forearm/Forearm/Gun/Barrel2
]


func _on_heart_body_entered(body):
	$AttackCooldown.stop()
	emit_signal("die", self)


func _on_aim_animation_finished(_anim_name):
	$AttackCooldown.start()


func _on_attack_cooldown_timeout():
	for barrel in _barrels:
		barrel.shoot()
