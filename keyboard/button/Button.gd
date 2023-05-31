@tool
extends MeshInstance3D

#TODO: Optimize with Multimesh
#TODO: Support long-press
#TODO: Support UTF
#TODO: Shift, Ctrl, Alt

signal pressed(key: Key)


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


func _on_area_3d_body_entered(_body):
	# All fingers must be lifted before it's considered pressed again
	if $Area3D.get_overlapping_bodies().size() == 1:
		$Keysound.play()
		emit_signal("pressed", key)


func is_pressed()->bool:
	return $Area3D.get_overlapping_bodies().size()


func _on_property_list_changed():
	var size = mesh.size
	$Area3D/CollisionPolygon3D.polygon = [Vector2(size.x/2, size.z/2),
										Vector2(size.x/2, -size.z/2),
										Vector2(-size.x/2, -size.z/2),
										Vector2(-size.x/2, size.z/2)]
	$Area3D/CollisionPolygon3D.depth = size.z
	
	$Label.font_size = min(size.x, size.z) * letter_to_button_ratio / $Label.pixel_size 
	$Label.outline_size = $Label.font_size * outline_to_font_ratio
	$Label.position.y = size.y/2 + 0.001 # Float outside Mesh, avoid jittering


