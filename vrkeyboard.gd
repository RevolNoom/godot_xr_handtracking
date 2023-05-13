extends Node3D


signal pressed(key: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	var keys = $QWERTY/Row1.get_children() + $QWERTY/Row2.get_children() + $QWERTY/Row3.get_children() 
	for k in keys:
		k.connect("pressed", _on_key_pressed)


func _on_key_pressed(key):
	emit_signal("pressed", key)
