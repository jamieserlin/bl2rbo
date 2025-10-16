extends CharacterBody3D
@onready var audio_manager = get_tree().get_first_node_in_group("audio_manager") 
## ^^ This is refferencing the e-audio_manager.tscn which must also be dragged into a new scene alongside the j-Player

##Camera References
@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.25
@onready var _camera_holder: Node3D = %CameraHolder
@onready var _camera: Camera3D = %Camera3D
@onready var coyote_time: Timer = $CoyoteTime

@onready var anim_sprite = $Node3D/AnimatedSprite3D

var using_controller = false
var in_dialogue = false
var can_interact = false
##Movement References
@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 25.0
@export var raw_input := Input.get_vector("MoveLeft", "MoveRight","MoveForward", "MoveBackward")

##Jump References
@export var is_starting_jump := Input.is_action_just_pressed("Jump") and is_on_floor()
@export var jump_impulse := 13.5
@export var _gravity = -30.0

##Dive References
@export var is_starting_dive := Input.is_action_just_pressed("RightClick")
@export var dive_impulse := 20.0
@export var has_dived = false;
@export var can_dive = true;

var _camera_input_direction := Vector2.ZERO


func _input(event:InputEvent) -> void:
	if event.is_action_pressed("LeftClick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("unbind"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
		using_controller = false
	else:
		using_controller = true


func _physics_process(delta: float) -> void:
	if using_controller:
		_camera_input_direction = Input.get_vector("Joy_left", 
		"Joy_right", "Joy_up", "Joy_down") * 3.5
	if get_tree().get_first_node_in_group("hippo_dialogue") != null:
		in_dialogue = true
	else:
		in_dialogue = false
	raw_input = Input.get_vector("MoveLeft", "MoveRight","MoveForward", "MoveBackward")
	
	if !in_dialogue:
		is_starting_jump = Input.is_action_just_pressed("Jump")
		
		
	is_starting_dive = Input.is_action_just_pressed("RightClick")
	##CAMERA
	_camera_holder.rotation.x += _camera_input_direction.y * delta
	## _camera_holder.rotation.x = clamp(_camera_holder.rotation.x, -PI /6.0, PI/3.0)
	_camera_holder.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	##MOVEMENT
	
	var was_on_floor = is_on_floor()
	var has_jumped = false
	

	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward *raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	##JUMPING
	velocity.y = y_velocity + _gravity * delta
	if is_starting_jump and (is_on_floor() || !coyote_time.is_stopped()):

		audio_manager.player_jump()
		velocity.y += jump_impulse
		has_jumped = true
		
	if !is_on_floor():
		#anim_sprite.stop()
		if $CameraHolder/SpringArm3D.position.y <= 0.1:
			$CameraHolder/SpringArm3D.position.y += 12 * delta
		
		anim_sprite.play("jump")
		
	##DIVING
	if velocity.x != 0 && is_on_floor():
		audio_manager.player_walk()
		anim_sprite.play("walk")
	
	if velocity.x == 0 && is_on_floor():
		anim_sprite.play("idle")
	
	if is_starting_dive and !has_dived and !is_on_floor():
		audio_manager.player_dive()
		velocity.y += jump_impulse /2
		if %Camera3D.fov <= 90:
			%Camera3D.fov += 1.5
			
		velocity = dive_impulse * -forward
		has_dived = true
	if is_on_floor():
		if $CameraHolder/SpringArm3D.position.y >= 0:
			$CameraHolder/SpringArm3D.position.y -= 10.0 * delta
		if %Camera3D.fov > 75:
			%Camera3D.fov -= 1
		has_dived = false;
		
	move_and_slide()
	if was_on_floor && !is_on_floor() && !has_jumped:
		print("Coyote Time")
		coyote_time.start()
