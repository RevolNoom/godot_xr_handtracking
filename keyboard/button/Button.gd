@tool
extends MeshInstance3D

class_name XRButton

#TODO: Optimize with Multimesh
#TODO: Support long-press
#TODO: Support UTF
#TODO: Shift, Ctrl, Alt

signal pressed(key: Key)
signal unpressed(key: Key)


@export var enabled: bool = true

@export var key: Key = KEY_NONE:
	set(value):
		key = value
		if get_child_count():
			custom_label = OS.get_keycode_string(key)


@export var custom_label: String = "":
	set(value):
		custom_label = value
		if get_child_count():
			$Label.text = custom_label

@export var toggle_mode: bool = false

@export var collision_shape_to_mesh_ratio: float = 1.0/3

@export var letter_to_button_ratio = 0.8:
	set(new_ratio):
		letter_to_button_ratio = new_ratio
		if get_child_count():
			var size = mesh.size
			$Label.font_size = min(size.x, size.z) * letter_to_button_ratio / $Label.pixel_size


@export var outline_to_font_ratio = 0.3:
	set(new_ratio):
		outline_to_font_ratio = new_ratio
		if get_child_count():
			$Label.outline_size = $Label.font_size * outline_to_font_ratio

var is_pressed: bool = false


func _ready():
	_on_property_list_changed()
	
	
func _on_area_3d_body_entered(_body):
	if not enabled:
		return
	# All fingers must be lifted before it's considered pressed again
	if $Area3D.get_overlapping_bodies().size() == 1:
		if toggle_mode:
			$Keysound.play()
			is_pressed = not is_pressed
			if is_pressed:
				emit_signal("pressed", key)
			else:
				emit_signal("unpressed", key)
		else:
			is_pressed = true
			$Keysound.play()
			emit_signal("pressed", key)


func _on_area_3d_body_exited(_body):
	if not enabled:
		return
	if $Area3D.get_overlapping_bodies().size() == 0:
		if not toggle_mode:
			is_pressed = false
			emit_signal("unpressed", key)


func _on_property_list_changed():
	var size = mesh.get("size")
	if size == null:
		return
		
	var width = size.x
	var height = size.z
	var depth = size.y
	$Area3D/CollisionPolygon3D.polygon = [Vector2(width/2, depth/2)* collision_shape_to_mesh_ratio,
										Vector2(width/2, -depth/2)* collision_shape_to_mesh_ratio,
										Vector2(-width/2, -depth/2)* collision_shape_to_mesh_ratio,
										Vector2(-width/2, depth/2)* collision_shape_to_mesh_ratio]
	$Area3D/CollisionPolygon3D.depth = height* collision_shape_to_mesh_ratio
	
	$Label.font_size = min(width, height) * letter_to_button_ratio / $Label.pixel_size 
	$Label.outline_size = $Label.font_size * outline_to_font_ratio
	$Label.position.y = depth/2 + 0.001 # Float outside Mesh, avoid jittering



