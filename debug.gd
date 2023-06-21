extends Label3D



func _on_timer_timeout():
	text = "FPS: " + str(Performance.get_monitor(Performance.Monitor.TIME_FPS))
