extends MasterCharacter3D
class_name Player3D

# <========================== Variables ====================================>


# <========================== Functions ========================================>


func _input(event: InputEvent) -> void:
	if !is_input_enabled:
		return
	if Input.is_action_just_pressed("dash"):
		dash()
	if (
		Input.is_action_just_pressed("jump") and 
		jump_count < max_jump_count and
		(can_jump || is_on_floor())
	): # is on floor or coyote timer or jump count less thn max jump count
		jump()
	if Input.is_action_just_pressed("attack"):
		attack()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move()
	update_state()
	update_animation()
