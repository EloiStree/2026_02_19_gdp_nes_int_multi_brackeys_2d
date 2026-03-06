extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0

@export var animated_sprite:AnimatedSprite2D 
@export var sword_direction:Node2D 

@export var arrow_scene: PackedScene
@export var arrow_rotation_center: Node2D
@export var arrow_start_point: Node2D
@export var arrow_direction_point: Node2D


@export_group("View State")
@export var direction:Vector2 = Vector2.ZERO
@export var is_jumping:bool 
@export var is_moving_left:bool 
@export var is_moving_right:bool 
@export var is_looking_up:bool
@export var is_looking_down:bool
@export var is_selecting_b_action:bool



signal on_b_action_state_changed(new_state:bool)
signal on_jumping_state_changed(new_state:bool)
signal on_moving_left_state_changed(new_state:bool)
signal on_moving_right_state_changed(new_state:bool)
signal on_looking_up_state_changed(new_state:bool)
signal on_looking_down_state_changed(new_state:bool)

signal on_b_action_started()
signal on_b_action_stopped()

func set_use_button_b_action(state:bool):
	var p = is_selecting_b_action
	is_selecting_b_action=state
	update_direction()
	if p!=is_selecting_b_action:
		emit_signal("on_b_action_state_changed", is_selecting_b_action)
		if is_selecting_b_action:
			emit_signal("on_b_action_started")
		else:
			emit_signal("on_b_action_stopped")


func start_using_b_action():
	set_use_button_b_action(true)
func stop_using_b_action():
	set_use_button_b_action(false)


@export var has_double_jump=false
@export var arrow_cooldown_time_seconds =0.5
@export var arrow_cooldown_tracker =0.5

func jump():
	if is_on_floor() :	
		has_double_jump=true
		velocity.y = jump_velocity
	else:
		if has_double_jump:
			has_double_jump=false
			velocity.y = jump_velocity
			

func start_jumping():
	set_jumping_state(true)

func shoot_arrow():
	if arrow_cooldown_tracker>0:
		return 
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	# Position de départ
	arrow.global_position = arrow_start_point.global_position
	# Direction = du joueur vers le point de spawn
	var dir = (arrow_direction_point.global_position - arrow_start_point.global_position).normalized()
	arrow.direction = dir
	arrow.rotation = dir.angle()
	arrow_cooldown_tracker = arrow_cooldown_time_seconds
	
func set_jumping_state(state:bool):
	var previous = is_jumping
	is_jumping = state
	if previous!=is_jumping and is_jumping:
		emit_signal("on_jumping_state_changed", is_jumping)
		if is_jumping:
			jump()

func set_moving_left_state(state:bool):
	var previous = is_moving_left
	is_moving_left = state
	update_direction()
	if previous!=is_moving_left:
		emit_signal("on_moving_left_state_changed", is_moving_left)

func set_moving_right_state(state:bool):
	var previous = is_moving_right
	is_moving_right = state
	update_direction()
	if previous!=is_moving_right:
		emit_signal("on_moving_right_state_changed", is_moving_right)


func stop_jumping():
	set_jumping_state(false)

func start_moving_left():	
	set_moving_left_state(true)

func stop_moving_left():
	set_moving_left_state(false)

func start_moving_right():
	set_moving_right_state(true)

func stop_moving_right():
	set_moving_right_state(false)

func set_look_up_state(state:bool):
	var previous = is_looking_up
	is_looking_up = state
	update_direction()

	if previous!=is_looking_up:
		emit_signal("on_looking_up_state_changed", is_looking_up)
		

func set_look_down_state(state:bool):
	var previous = is_looking_down
	is_looking_down = state
	update_direction()
	if previous!=is_looking_down:
		emit_signal("on_looking_down_state_changed", is_looking_down)


func update_direction():
	var direction_vertical := 0
	if is_looking_up:
		direction_vertical -= 1
	if is_looking_down:
		direction_vertical += 1
	direction.y = direction_vertical

	var direction_horizontal := 0
	if is_moving_left:
		direction_horizontal -= 1
	if is_moving_right:
		direction_horizontal += 1
	direction.x = direction_horizontal


func _physics_process(delta: float) -> void:

	if arrow_cooldown_tracker>0:	
		arrow_cooldown_tracker-=delta
	
	update_direction()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction_horizontal = direction.x
	if direction_horizontal:
		velocity.x = direction_horizontal * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)


	# Flip the Sprite.
	if direction_horizontal > 0:
		animated_sprite.flip_h = false
		sword_direction.scale.x =1
	elif direction_horizontal < 0:
		animated_sprite.flip_h = true
		sword_direction.scale.x =-1

	# Play animations.
	if is_on_floor():
		if direction_horizontal == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("Run")
	else:
		animated_sprite.play("Jump")
	
	move_and_slide()
	rotate_bow()
	
#func rotate_bow():
	#var dir: Vector2 = direction
	#if dir.length() == 0:
		#return
	#var center = arrow_rotation_center.global_position
	#var spawn_point = arrow_start_point.global_position
	#var local_direction2D: Vector2 = dir.normalized()
	#arrow_rotation_center.rotation = local_direction2D.angle()

#func rotate_bow():
	#var dir: Vector2 = direction
	#if dir.length() == 0:
		#return
#
	#var local_direction2D: Vector2 = dir.normalized()
	#var angle = local_direction2D.angle()
#
	## 8 directions = 360 / 8 = 45 degrees
	#var step = PI / 4  # 45 degrees in radians
#
	#var snapped_angle = round(angle / step) * step
#
	#arrow_rotation_center.rotation = snapped_angle

func rotate_bow():
	var dir: Vector2 = direction
	if dir.length() == 0:
		return

	var n = dir.normalized()

	var snapped = Vector2(
		sign(n.x) if abs(n.x) > 0.382 else 0,
		sign(n.y) if abs(n.y) > 0.382 else 0
	)

	arrow_rotation_center.rotation = snapped.angle()
# func _physics_process(delta: float) -> void:
# 	# Add the gravity.
# 	if not is_on_floor():
# 		velocity += get_gravity() * delta

# 	# Handle jump.
# 	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
# 		velocity.y = jump_velocity

# 	# Get the input direction and handle the movement/deceleration.
# 	# As good practice, you should replace UI actions with custom gameplay actions.
# 	var direction := Input.get_axis("ui_left", "ui_right")
# 	if direction:
# 		velocity.x = direction * speed
# 	else:
# 		velocity.x = move_toward(velocity.x, 0, speed)

# 	move_and_slide()
