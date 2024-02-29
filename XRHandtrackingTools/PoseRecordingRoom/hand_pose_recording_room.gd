## A room filled with [HandPoseCaptureArea]s to help developers record
## their custom hand poses for their game.
##
## Here, you can add as many [HandPoseCaptureArea]s as you like
## and then put your hands inside to define your own poses.
##
## On Meta Quest 2, pressing the "Save" button does save the file to external storage,
## but it doesn't show on file explorer. 
## To work around this problem, there's a "Print" button to print out the resource file.
## Here's how I create my records:
##
## - Set this scene as your main scene.
##
## - Enable "Debug -> Deploy with Remote Debug" in the editor menu bar (upper left corner).
##
## - Run this scene on your headset. 
##
## - Put your hands in [HandPoseCaptureArea] to record your hand poses.
##
## - Press "Save" button to save the data to local storage. 
##
## - Press "Print" button to print the data of the poses to your Godot editor output console.
## 
## - Copy all the text and put it in your own .tres file.
##
## Refers to https://godotvr.github.io/godot-xr-tools/docs/hand_poses/
## for a list of hand poses
extends Node3D
class_name HandPoseRecordingRoom

@export var hand_catalogue: HandPoseCatalogue
var interface: XRInterface

static var default_save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS, true) \
		+ "/pose_records.tres"

# Called when the node enters the scene tree for the first time.
func _ready():
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("XR READY!")
		get_viewport().use_xr = true
	
	
	var permissions: PackedStringArray = OS.get_granted_permissions()
	if not permissions.has("android.permission.READ_EXTERNAL_STORAGE") \
		or not permissions.has("android.permission.WRITE_EXTERNAL_STORAGE"):
			OS.request_permissions()
		
	hand_catalogue = load(default_save_path) as HandPoseCatalogue
	
	if hand_catalogue == null:
		hand_catalogue = HandPoseCatalogue.new()
		
	for hand in hand_catalogue.poses.keys():
		for pose in hand_catalogue.poses[hand].keys():
			var hpca = $PoseBoard/AllPoses.get_node_or_null(pose.capitalize()) as HandPoseCaptureArea
			if hpca == null:
				printerr("""Pose %s presented in HandPoseCatalogue, 
				but no HandPoseCaptureArea pose of same name found.""" % pose)
				continue
			(hand_catalogue.poses[hand][pose] as HandPose).override_skeleton_pose(
				hpca.get_hand(hand))
			
	for area in $PoseBoard/AllPoses.get_children():
		area.connect("recorded", _on_area_new_pose_recorded)
		
	var board_side = ceili(sqrt($PoseBoard/AllPoses.get_child_count()))
	for i in range(0, $PoseBoard/AllPoses.get_child_count()):
		$PoseBoard/AllPoses.get_child(i).position = Vector3((i%board_side)*0.2, int(1.0*i/board_side) * 0.2, 0)
	

func _on_area_new_pose_recorded(pose: HandPose):
	print("Recorded ", pose.name, " ", "left" if pose.hand == OpenXRHand.HAND_LEFT else "right")
	hand_catalogue.poses[pose.hand][pose.name] = pose


func _on_save_pressed(_key):
	var err = ResourceSaver.save(hand_catalogue, default_save_path)
	if err == OK:
		print("Saved to %s" % default_save_path)
	else:
		print("Can't open file %s to write" % default_save_path.get_path_absolute)


## Cut up the file into many lines, 
## avoid console output overflow
var file_string: PackedStringArray
var current_substring_index: int = 0
func _on_print_pressed(_key):
	print("Printing HandPoseCatalogue resource file:")
	var file = FileAccess.open(default_save_path, FileAccess.READ)
	file_string = file.get_as_text().split("\n")
	current_substring_index = 0
	$Timer.start()


func _on_timer_timeout():
	const batch_size = 10
	for i in range(0, batch_size):
		if current_substring_index < file_string.size():
			print(file_string[current_substring_index])
			current_substring_index += 1
		else:
			break
			$Timer.stop()
