extends CharacterBody3D
@onready var camera_3d = $Camera3D

const MAX_SPEED = 20
const ACCELERATION = 1
const SLOWDOWN_SPEED = 0.5
const GRAVITY = 7

var mouse_move: Vector2
var mouse_sensitivity = 0.1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var gravity_dir = position.direction_to(get_parent().get_node("Planet").transform.origin)
	up_direction = -gravity_dir
	
	var orientation = Quaternion(basis.y, -gravity_dir) * global_basis.get_rotation_quaternion()
	global_rotation = orientation.get_euler()
	
	var local_velocity = velocity * global_basis
	var local_xz = Vector3(local_velocity.x, 0, local_velocity.z)
	
	velocity += GRAVITY * gravity_dir * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity -= 5 * gravity_dir
	
	if not is_on_floor():
		velocity = velocity.move_toward(velocity - (global_basis * local_xz), SLOWDOWN_SPEED / 2)
	
	var raw_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input = Vector3(raw_input.x, 0, raw_input.y)
	
	var pct1 = local_xz.length() / MAX_SPEED
	var pct2 = local_xz.normalized().dot(input.normalized())
	
	velocity = velocity.move_toward(velocity + (global_basis * input), ACCELERATION * (1.0 - (pct1 * pct2)))
	input = Vector3.ZERO
	
	var stop = 1 if !input else 0

	# FOLLOWING LINE IS NOT NEEDED, CHECK VIDEO DESCRIPTION
	var pct = local_velocity.normalized().dot(Vector3(0, local_velocity.y, 0).normalized())

	# OMIT (1.0 - pct), CHECK VIDEO DESCRIPTION
	velocity = velocity.move_toward(velocity - (global_basis * local_xz * stop), (1.0 - pct) * SLOWDOWN_SPEED)
	
	_update_camera()
	mouse_move = Vector2.ZERO
	
	move_and_slide()

func _update_camera():
	rotate(basis.y, deg_to_rad(-mouse_move.x) * mouse_sensitivity)
	camera_3d.rotate(camera_3d.basis.x, deg_to_rad(-mouse_move.y) * mouse_sensitivity)
	camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 90)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_move = event.relative
