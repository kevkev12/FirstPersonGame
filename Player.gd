extends KinematicBody

var camera_angle = 0
var mouse_sensitivity = 0.3
var camera_change = Vector2()

var velocity = Vector3()
var direction = Vector3()

const FLY_SPEED = 40
const FLY_ACCELERATION = 4

var gravity = -9.8 * 3

const MAX_SPEED = 20
const MAX_RUNNING_SPEED = 30
const ACCELERATION = 2
const DEACCELERATION = 6

var jump_height = 15
var has_contact = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _physics_process(delta):
	aim()
	walk(delta)
		
		
	
func aim():
	if camera_change.length() > 0:
		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
		
		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 85 and change + camera_angle > -85:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()

func _input(event):
	
	if event is InputEventMouseMotion:
		camera_change = event.relative
	
		
func fly(delta):
	
	direction = Vector3()
	
	var aim = $Head/Camera.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
		
	direction = direction.normalized()
	
	var target = direction * FLY_SPEED
	
	velocity = velocity.linear_interpolate(target, FLY_ACCELERATION * delta)
	
	
	move_and_slide(velocity)
	
func walk(delta):
	direction = Vector3()
	
	var aim = $Head/Camera.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
		
	direction = direction.normalized()
	
	if (is_on_floor()):
		has_contact = true
	else:
			has_contact = false
	if (has_contact and !is_on_floor()):
		move_and_collide(Vector3(0, -1, 0))
		
	velocity.y += gravity * delta
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DEACCELERATION
		
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	velocity = velocity.linear_interpolate(target, FLY_ACCELERATION * delta)
	
	if has_contact and Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
		has_contact = false
	
	move_and_slide(velocity, Vector3(0, 1, 0))
	
