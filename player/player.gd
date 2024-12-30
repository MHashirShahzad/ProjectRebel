extends Entity3D
class_name Player3D

# <========================== Variables ====================================>


# <========================== Functions ========================================>


func buffered_input(delta: float) -> void:
	if !is_action_enabled:
		return
	if InputBuffer.is_action_press_buffered("dash"):
		dash()
		
	if (
		InputBuffer.is_action_press_buffered("jump") and 
		jump_count < max_jump_count and
		(can_jump || is_on_floor())
	): # is on floor or coyote timer or jump count less thn max jump count
		jump()
	if InputBuffer.is_action_press_buffered("attack"):
		attack()



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move()
	update_state()
	update_animation()

func move() -> void:
	if is_movement_enabled:
		wish_dir = Input.get_vector("left", "right", "forward", "backward")
	else:
		wish_dir = Vector2.ZERO
		
	direction = (global_basis * Vector3(wish_dir.x, 0, wish_dir.y)).normalized()
	if direction:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction)
		
	var was_on_floor := is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		just_left_ground()
		
	if is_on_floor() and !was_on_floor:
		just_landed()
	
