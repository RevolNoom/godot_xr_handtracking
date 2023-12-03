extends Area3D
class_name XRSnapArea

## This class snaps XRPickable's position and rotation to it.
## It assumes all objects entering are of class XRPickable
## Also, each XRPickable class must contains a node named 

## Snap XRPickable when it enters
@export var snap_on_enter: bool = false
## Snap XRPickable when it exits 
@export var snap_on_exit: bool = false
## Snap XRPickable when it emits "dropped" signal
@export var snap_on_dropped: bool = true

## If true, move XRPickable to XRSnapArea's position on snapping
@export var snap_position = true
## If true, rotate XRPickable to XRSnapArea's rotation on snapping
@export var snap_rotation = true
## How fast XRPickable will snap to XRSnapArea
@export var snap_duration : float = 0

func _on_body_entered(body: XRPickable):
	pass # Replace with function body.

func _on_body_exited(body: XRPickable):
	pass # Replace with function body.

func _snap(body: XRPickable):
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var pickable_layer = GodotXRHandtrackingToolkit.get_layer_index("pickable") 
	if pickable_layer == -1:
		warnings.append("""Physic layer 'pickable' not found in 
		"Project > Project Settings > Layer Names > 3D Physic".""") 
	else:
		if collision_mask & (1 << pickable_layer) == 0:
			warnings.append("""Collision mask should contain "pickable" layer 
			(layer %d)""" % pickable_layer)
			
		if collision_mask & ~(1 << pickable_layer) != 0:
			warnings.append("""XRSnapArea assumes all objects entering it 
			are of class XRPickable. You should turn on only layer %d and 
			ignore the rest""" % pickable_layer)
	return warnings
		
