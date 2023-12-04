@tool
extends Node3D

@export var enabled := true:
	set(enable):
		enabled = enable
		
		$Picker.enabled = enabled
		$CurrentPoint.enabled = enabled
		
		$Destination.visible = enabled
		$Pointer.visible = enabled
		
		set_process(enabled)


## How transparent the pointer is when it doesn't hit anything interactable
@export var idle_alpha = 50
## How transparent the pointer is when it hit something interactable
@export var pickable_alpha = 255


## Layer of raycast that hints pickables
## Flashes when hovered over pickable
@export_flags_3d_physics var picker_mask = 0:
	set(value):
		picker_mask = value
		if get_child_count():
			$Picker.collision_mask = value

## Layer of raycast that hints currently pointed position
## Default to all layers
@export_flags_3d_physics var current_point_mask = ~0:
	set(value):
		current_point_mask = value
		if get_child_count():
			$CurrentPoint.collision_mask = value
		

func _ready():
	if Engine.is_editor_hint():
		set_physics_process(false)
		set_process(false)
	enabled = enabled
	picker_mask = picker_mask
	current_point_mask = current_point_mask


func is_colliding() -> bool:
	return $Picker.is_colliding()


func get_collider() -> XRPickArea:
	return $Picker.get_collider()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Picker.is_colliding():
		$Pointer.mesh.material.albedo_color.a = pickable_alpha
		$Destination.mesh.material.albedo_color.a = pickable_alpha
		$Destination.global_position = $Picker.get_collision_point()
	else:
		$Pointer.mesh.material.albedo_color.a = idle_alpha
		$Destination.mesh.material.albedo_color.a = idle_alpha
		if $CurrentPoint.is_colliding():
			$Destination.global_position = $CurrentPoint.get_collision_point()
		else:
			$Destination.global_position = $Pointer/DestinationParkingSlot.global_position

		
