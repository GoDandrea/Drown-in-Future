extends Spatial

const MOVE_MARGIN = 20
const MOVE_SPEED = 0.005

var team = 0
var selected_units = []
onready var selection_box = $SelectionBox
var start_sel_pos = Vector2()

const ray_length = 1000
onready var cam = $Camera

func _process(_delta):
	
	var m_pos = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("main_command"):
		move_selected_units(m_pos)
	if Input.is_action_just_pressed("alt_command"):
		selection_box.start_sel_pos = m_pos
		start_sel_pos = m_pos
	if Input.is_action_pressed("alt_command"):
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("alt_command"):
		select_units(m_pos)
		
	$Camera.father_rot = rotation_degrees[1]
		
		#smooth movement
	var inpx = (int(Input.is_action_pressed("ui_right"))
	                   - int(Input.is_action_pressed("ui_left")))
	var inpy = (int(Input.is_action_pressed("ui_down"))
	                   - int(Input.is_action_pressed("ui_up")))
	#position.x = lerp(position.x, position.x + inpx *speed * zoom.x,speed * delta)
	#position.y = lerp(position.y, position.y + inpy *speed * zoom.y,speed * delta)
	


	
func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)

func get_unit_from_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	if result and "team" in result.collider and result.collider.team == team:
		return result.collider

func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == team and box.has_point(cam.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units
	
func select_units(m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		var u = get_unit_from_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units

func move_selected_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		for unit in selected_units:
			unit.move_to(result.position)
