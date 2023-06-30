extends Node3D

# POSE RECORDING ROOM
# Here, you can add as many Pose Capture Areas as you like
# and then put your hands inside to define your own poses
#
# There're already over a dozen poses already, but suits yourself
# with poses that fit your needs
#
# Because I can't find a way to save the poses information 
# to external storage, here's what you should do:
#
# +) Set this scene as your main scene
# +) Records your hand poses
# +) Press 3D Save button with your hand to save them to app's 
#	data directory. When you open the game again, the poses 
#	will be automatically loaded again
# +) Enable "Debug -> Deploy with Remote Debug"
#	Press Print to print the information of the poses to console.
#	You may then copy all the text and put it in a JSON file for 
#	future use.
#
# If you complain that's too much to do, hey, think of a better
# way to do it then. I'm also very tired with it, you know?
#
# Refers to https://godotvr.github.io/godot-xr-tools/docs/hand_poses/
# for a list of a lot of hand poses


var filepath = "user://pose_records.json"
var recorded_poses: Dictionary = {
	"left": {},
	"right": {}}

var interface: XRInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("XR READY!")
		get_viewport().use_xr = true

	var file = FileAccess.open(filepath, FileAccess.READ)
	var json = null
	if file != null:\
		json = JSON.parse_string(\
			file.get_as_text())
		
	if json != null:
		recorded_poses = json
		for hand in json.keys():
			for pose in json[hand].keys():
				var hpca = $PoseBoard/AllPoses.get_node_or_null(pose.capitalize())
				if hpca == null:
					printerr("No pose " + pose + " found.")
					continue
				hpca.apply_pose_on_hand(hpca.get_node("Hands/"+hand), json[hand][pose])
	
	
	for area in $PoseBoard/AllPoses.get_children():
		area.connect("recorded", _on_area_new_pose_recorded)
	for i in range(0, $PoseBoard/AllPoses.get_child_count()):
		$PoseBoard/AllPoses.get_child(i).position = Vector3((i%5)*0.2, int(i/5) * 0.2, 0)
	
	if file != null:
		file.close()
		

func _on_area_new_pose_recorded(pose_info: Dictionary):
	var hand = pose_info.keys()[0]
	var pose_name = pose_info[hand].keys()[0]
	print("Recorded " + pose_name)
	recorded_poses[hand][pose_name] = pose_info[hand][pose_name]


func SaveToFile(text_string):
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file != null:
		file.store_string(text_string)
		file.flush()
		file.close()
		print("Saved to " + file.get_path_absolute())
	else:
		print("Can't open file to write")


func get_formatted_json(rec_poses) -> String:
	var json = JSON.stringify(rec_poses)
	#Do some formatting to make it easier on the eyes
	json = json.replace(":{", ":\n{\n")
	json = json.replace("}", "\n}")
	json = json.replace(",\"", ",\n\"")
	return json
	

func _on_save_pressed(_key):
	SaveToFile(JSON.stringify(recorded_poses))


var json_str: String
func _on_print_pressed(_key):
	print("Recorded_poses: ")
	json_str = get_formatted_json(recorded_poses)
	$Timer.start()


func _on_timer_timeout():
	const SUBSTR = 1500
	var i = json_str.find("\n", SUBSTR)
	if i >= SUBSTR:
		print(json_str.substr(0, i))
		json_str = json_str.substr(i+1)
	else:
		print(json_str)
		json_str = ""
		$Timer.stop()
