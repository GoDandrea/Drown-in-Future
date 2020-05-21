extends Camera

const MOVE_MARGIN = 20
const MOVE_SPEED = 0.005

var zoomspeed = 10.0
var zoommargin = 0.1
var zoomfactor = 1.0
var zoomDef = 64
var zoomMin = 32
var zoomMax = 128
var zooming = false

var father_rot

var mousepos = Vector2()
var mouseposGlobal = Vector2()
var is_dragging = false
var move_to_point = Vector2()


func _process(delta):
	
	var m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos)
	
	#zoom in
	size = lerp(size, size * zoomfactor, zoomspeed * delta)
	size = clamp(size, zoomMin, zoomMax)

	if not zooming:
		zoomfactor = 1.0

func calc_move(m_pos):
	var v_size = get_viewport().size
	var move_vec = Vector2()
	if m_pos.x < MOVE_MARGIN:
		move_vec.x -= 0.1
	if m_pos.y < MOVE_MARGIN:
		move_vec.y -= 0.1
	if m_pos.x > v_size.x - MOVE_MARGIN:
		move_vec.x += 0.1
	if m_pos.y > v_size.y - MOVE_MARGIN:
		move_vec.y += 0.1
	move_vec *= MOVE_SPEED
	
	var g_rotation = global_transform.basis.get_euler()
	if not ((rad2deg(g_rotation[1]) + 100*-rad2deg(move_vec.x) > 40 + father_rot) or (rad2deg(g_rotation[1]) + 100*-rad2deg(move_vec.x) < -40 + father_rot)):
		global_rotate(Vector3(0,1,0), -rad2deg(move_vec.x))
	if not ((rotation_degrees[0] + 100*-rad2deg(move_vec.y) > 10) or (rotation_degrees[0] + 100*-rad2deg(move_vec.y) < -75)):
		rotate_object_local(Vector3(1,0,0), -rad2deg(move_vec.y))

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.button_index == BUTTON_WHEEL_UP:
				zoomfactor -= 0.05 * zoomspeed
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoomfactor += 0.05 * zoomspeed
		else:
			zooming = false
	
	if event is InputEventMouse:
		mousepos = event.position
