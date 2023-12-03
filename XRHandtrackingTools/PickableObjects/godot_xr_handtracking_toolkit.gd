class_name GodotXRHandtrackingToolkit
## This script contains miscellaneous helper functions

## Return the index (0-based) of physic layer with @layer_name if it exists
## Else return -1
static func get_layer_index(layer_name: String) -> int:
	for i in range(1, 33):
		var layer_i_name = ProjectSettings.get_setting("layer_names/3d_physics/layer_%d" % i)
		if layer_i_name == layer_name:
			return i - 1
	return -1

