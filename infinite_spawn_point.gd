extends Marker3D

const RESPAWN_COMMAND := "robot"

var droids := []

var alive_droids := []

func _ready():
	for path in get_children():
		if path is PathFollow3D:
			for pathfollow in path.get_children():
				var droid = pathfollow.get_child(0).get_child(0)
				droids.push_back(droid)
				droid.connect("died", _on_droid_died)


func _on_droid_died(droid):
	alive_droids.erase(droid)


func _on_timer_timeout():
	var kbs = get_tree().get_nodes_in_group("keyboard")
	for kb in kbs:
		kb.connect("text_submitted", _on_keyboard_text_submitted)


func _on_keyboard_text_submitted(new_text):
	if new_text == RESPAWN_COMMAND:
		reset_droids()


func reset_droids():
	print("reset")
	alive_droids = droids.duplicate()
	for droid in droids:
		var pathfollow = droid.get_parent().get_parent() as PathFollow3D
		pathfollow.progress_ratio = 0
		droid.reset_anims()
		droid.walk()
		droid.attack()
		
	print("resetted")


func _process(delta):
	for droid in alive_droids:
		var pathfollow = droid.get_parent().get_parent() as PathFollow3D
		if pathfollow: 
			if pathfollow.progress_ratio < 1:
				pathfollow.progress += droid.speed * delta
			else:
				droid.die()
