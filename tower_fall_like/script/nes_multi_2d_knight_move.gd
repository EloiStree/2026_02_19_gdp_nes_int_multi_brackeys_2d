extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0


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


func jump():
	if is_on_floor():
		velocity.y = jump_velocity

func start_jumping():
	set_jumping_state(true)


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
	update_direction()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction_horizontal = direction.x
	if direction_horizontal:
		velocity.x = direction_horizontal * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


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


func _on_nes_multi_int_to_nes_signal_arrow_down_pressed(pressed: bool) -> void:
	pass # Replace with function body.
