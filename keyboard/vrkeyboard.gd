extends Node3D


signal pressed(key: InputEventKey)
signal unpressed(key: InputEventKey)


var _shift_pressed: int = 0
var _alt_pressed: int = 0
var _ctrl_pressed: int = 0


@export var enabled: bool = true:
	set(enable):
		enabled = enable
		if get_child_count() > 0:
			$QWERTY.enabled = enable
			$SetTransformRemote.enabled = enable# false


func _ready():
	enabled = enabled


func _on_qwerty_pressed(keycode):
	match keycode:
		KEY_ALT: 
			_alt_pressed += 1
		
		KEY_SHIFT:
			_shift_pressed += 1
		
		KEY_CTRL:
			_ctrl_pressed += 1
		
		_:
			var key = InputEventKey.new()
			key.keycode = keycode
			key.shift_pressed = _shift_pressed > 0
			key.alt_pressed = _alt_pressed > 0
			key.ctrl_pressed = _ctrl_pressed > 0
			emit_signal("pressed", key)


func _on_qwerty_unpressed(keycode):
	match keycode:
		KEY_ALT: 
			_alt_pressed -= 1
		
		KEY_SHIFT:
			_shift_pressed -= 1
		
		KEY_CTRL:
			_ctrl_pressed -= 1
		
		_:
			var key = InputEventKey.new()
			key.keycode = keycode
			key.shift_pressed = _shift_pressed > 0
			key.alt_pressed = _alt_pressed > 0
			key.ctrl_pressed = _ctrl_pressed > 0
			emit_signal("unpressed", key)


func _on_setting_button_pressed(_key):
	$SetTransformRemote.enabled = true
	$SetTransformRemote.visible = true


func _on_setting_button_unpressed(_key):
	$SetTransformRemote.enabled = false
	$SetTransformRemote.visible = false
