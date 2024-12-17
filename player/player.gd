extends MasterCharacter3D
class_name Player3D

# <========================== Variables ====================================>


# <========================== Functions ========================================>


func _buffered_input(delta: float) -> void:
	if !is_action_enabled:
		return
	if InputBuffer.is_action_press_buffered("dash"):
		_dash()
		
	if (
		InputBuffer.is_action_press_buffered("jump") and 
		jump_count < max_jump_count and
		(can_jump || is_on_floor())
	): # is on floor or coyote timer or jump count less thn max jump count
		_jump()
	if InputBuffer.is_action_press_buffered("attack"):
		_attack()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_move()
	_update_state()
	_update_animation()
