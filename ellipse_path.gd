@tool
extends Path3D

enum SpreadMode{
	FROM_END,
	CENTER_OUT
}


@export var clockwise: bool = false:
	set(value):
		clockwise = value
		rebuild_curve()
		

@export var spread_from_center: bool = false:
	set(value):
		spread_from_center = value
		rebuild_curve()


@export var width: float = 0.5:
	set(value):
		if value > 0:
			width = value
			rebuild_curve()
			
@export var height: float = 0.5:
	set(value):
		if value > 0:
			height = value
			rebuild_curve()


@export var points = 10:
	set(value):
		if value > 1:
			points = value
			rebuild_curve()


@export_range(0, 2*PI) var fan_angle: float = PI:
	set(value):
		fan_angle = value
		rebuild_curve()


func rebuild_curve():
	curve.clear_points()
	var start_angle = {
		not spread_from_center and not clockwise: 0,
			spread_from_center and not clockwise: (fan_angle-PI)/2,
			spread_from_center and     clockwise: -(fan_angle+PI)/2,
		not spread_from_center and     clockwise: -PI,
	}
	var phi = start_angle[true]
	for i in range(0, points):
		var t = fan_angle/(points-1) * (i if clockwise else -i)
		curve.add_point(Vector3(width*cos(phi + t), 0, height*sin(phi + t)))
	rearrange_pathfollow_children()


func rearrange_pathfollow_children():
	var pfl: Array[PathFollow3D] = []
	for child in get_children():
		if child is PathFollow3D:
			pfl.append(child)
	if pfl.size() > 0:
		pfl[0].progress_ratio = 0
		for i in range(1, pfl.size()):
			pfl[i].progress_ratio = float(i)/(pfl.size()-1)


func _on_child_entered_tree(node):
	rearrange_pathfollow_children()


func _on_child_exiting_tree(node):
	rearrange_pathfollow_children()
