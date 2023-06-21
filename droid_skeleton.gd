@tool
extends Skeleton3D

var bones = [
	"Hip", "Hip_L", "Hip_R", "Body", 
	
	"Shoulder_L", "Muscle_L", "Forearm_L", 
	"Hand_L", "Fingers_L", "Finger_Tips_L",
	"Thumb_L", "Thumb_Tip_L",
	
	"Shoulder_R", "Muscle_R", "Forearm_R", 
	"Hand_R", "Fingers_R", "Finger_Tips_R",
	"Thumb_R", "Thumb_Tip_R",
	
	"Thigh_L", "Shin_L", "Foot_L",
	"Thigh_R", "Shin_R", "Foot_R"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	for bone in bones:
		add_bone(bone)
