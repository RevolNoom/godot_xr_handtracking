extends Node3D

# Refers to https://godotvr.github.io/godot-xr-tools/docs/hand_poses/
# for a list of a lot of hand poses

#var filepath = "/storage/emulated/0/Download/poses_records.json"
var recorded_poses: Dictionary


var interface: XRInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("XR READY!")
		get_viewport().use_xr = true
		
		
	#OS.request_permissions()
#	var file = FileAccess.open(filepath, FileAccess.READ)
	var json = null
#	if file != null:
#		json = JSON.parse_string(\
#			file.get_as_text())
		
	if json == null or\
		json == {}:
		recorded_poses = {
			"left": {},
			"right": {}}
	
	
	for area in $AllPoses.get_children():
		area.connect("recorded", _on_area_new_pose_recorded)
	for i in range(0, $AllPoses.get_child_count()):
		$AllPoses.get_child(i).position = Vector3((i%5)*0.2, int(i/5) * 0.2, 0)
	
	#if file != null:
	#	file.close()
		

func _on_area_new_pose_recorded(pose_info: Dictionary):
	var hand = pose_info.keys()[0]
	var pose_name = pose_info[hand].keys()[0]
	print("Recorded " + pose_name)
	recorded_poses[hand][pose_name] = pose_info[hand][pose_name]



func SaveToFile():
	#var file = FileAccess.open(filepath, FileAccess.WRITE)
	var file
	if file != null:
		file.store_string(json_str)
		file.flush()
		file.close()
		print("Saved to directory " + file.get_path_absolute())
	else:
		print("Can't open file to write")
	

var json_str
func _on_print_save_pressed(_key):
	#print("Recorded_poses: ")
	json_str = JSON.stringify(recorded_poses)
	#Do some formatting to make it easier on the eyes
	#json_str = json_str.replace(":{", ":\n{\n")
	#json_str = json_str.replace("}", "\n}")
	#json_str = json_str.replace(",\"", ",\n\"")
	#SaveToFile()
	$Timer.start()


func _on_timer_timeout():
	const SUBSTR = 2000
	if json_str.length() >= SUBSTR:
		print(json_str.substr(0, SUBSTR))
		json_str = json_str.substr(SUBSTR)
	else:
		print(json_str)
		json_str = ""
		$Timer.stop()
