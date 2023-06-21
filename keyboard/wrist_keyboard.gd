@tool
extends Node3D

signal text_submitted(new_text)


# Called when the node enters the scene tree for the first time.
func _ready():
	var gap = 0.005
	var size = 0.02
	for row in $Keys.get_children():
		for i in range(0, row.get_child_count()):
			var key = row.get_child(i)
			key.position = Vector3(0, 0, (size + gap) * (i - (row.get_child_count()-1)*0.5))
			key.connect("pressed", _on_key_pressed)


func _on_key_pressed(key: Key):
	var k = InputEventKey.new()
	k.keycode = key
	$Code.put_char(k)
	
	
	
func _on_code_text_submitted(new_text):
	emit_signal("text_submitted", new_text)
	$Code.text = ""


func _on_power_pressed(key):
	$Code.text = ""
	for nodes in [$Keys, $Code, $Label]:
		nodes.show()
	for row in $Keys.get_children():
		for i in range(0, row.get_child_count()):
			row.get_child(i).enabled = true


func _on_power_unpressed(key):
	for nodes in [$Keys, $Code, $Label]:
		nodes.hide()
	for row in $Keys.get_children():
		for i in range(0, row.get_child_count()):
			row.get_child(i).enabled = false
