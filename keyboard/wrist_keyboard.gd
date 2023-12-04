@tool
extends Node3D

signal text_submitted(new_text)

@export var gap : float = 0.008:
	set(value):
		if value >= 0:
			gap = value
			_rearrange_buttons()
			
@export var size : float= 0.016:
	set(value):
		if value >= 0:
			size = value
			_rearrange_buttons()

# Called when the node enters the scene tree for the first time.
func _ready():
	_rearrange_buttons()
	for row in $Keys.get_children():
		if not row is Label3D:
			for i in range(0, row.get_child_count()):
				row.get_child(i).connect("pressed", _on_key_pressed)


func _on_key_pressed(key: Key):
	var k = InputEventKey.new()
	k.keycode = key
	$Keys/Code.put_char(k)


func _on_code_text_submitted(new_text):
	$Keys/Code.text = ""
	emit_signal("text_submitted", new_text)


func _on_power_pressed(_key):
	$Keys/Code.text = ""
	$Keys.show()
	for row in $Keys.get_children():
		if not row is Label3D:
			for i in range(0, row.get_child_count()):
				row.get_child(i).enabled = true


func _on_power_unpressed(_key):
	$Keys.hide()
	for row in $Keys.get_children():
		if not row is Label3D:
			for i in range(0, row.get_child_count()):
				row.get_child(i).enabled = false


func _rearrange_buttons():
	for row in $Keys.get_children():
		if not row is Label3D:
			for i in range(0, row.get_child_count()):
				var key = row.get_child(i)
				key.position = Vector3(0, 0,\
						(size + gap) * (i - (row.get_child_count()-1)*0.5))
	
