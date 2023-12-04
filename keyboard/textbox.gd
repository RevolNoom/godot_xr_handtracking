extends Label3D

class_name LineEdit3D

signal text_submitted(new_text: String)
signal text_changed(new_text: String)


const modifier_keys = [KEY_SHIFT, KEY_CTRL, KEY_ALT]
	
	
func put_char(key: InputEventKey):
	if key.keycode in modifier_keys:
		return
	
	var text_modified: bool = false
	
	if key.keycode == KEY_ENTER:
		emit_signal("text_submitted", text)
		return
		
	if is_ascii(key.keycode):
		var index = key.keycode - KEY_A
		if key.shift_pressed:
			text += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[index] 
		else:
			text += "abcdefghijklmnopqrstuvwxyz"[index] 
		text_modified = true

	elif is_digit(key.keycode):
		var index = key.keycode - KEY_0
		text += "0123456789"[index]
		text_modified = true
	elif key.keycode == KEY_SPACE:
		text += " "
		text_modified = true
	elif key.keycode == KEY_BACKSPACE:
		if text.length() > 0:
			text = text.erase(text.length()-1)
			text_modified = true

	if text_modified:
		emit_signal("text_changed", text)


func _on_vr_keyboard_pressed(key: InputEventKey):
	put_char(key)


func is_ascii(keycode: Key):
	return KEY_A <= keycode and keycode <= KEY_Z


func is_digit(keycode: Key):
	return KEY_0 <= keycode and keycode <= KEY_9


