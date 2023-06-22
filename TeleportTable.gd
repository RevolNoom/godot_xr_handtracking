extends StaticBody3D

@export var touch_sec_until_teleport: float = 1

var touch_time: Array[Array] = []

func _on_teleport_area_body_entered(body):
	touch_time.push_back([body, Time.get_ticks_msec()])
	

func _on_teleport_area_body_exited(body):
	var erase = []
	for record in touch_time:
		if record[0] == body:
			erase.push_back(record)
	while erase.size():
		touch_time.erase(erase.pop_back())


func teleport_to_drop_point(body):
	body.global_position = $mesh_Material_0/DropPoint.global_position
	if body is GrandInquisitorLightsaber:
		body.reset()


func _process(_delta):
	for record in touch_time:
		if record[1] + touch_sec_until_teleport*1000 < Time.get_ticks_msec():
			teleport_to_drop_point(record[0])
	
