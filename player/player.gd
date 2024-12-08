extends MasterCharacter3D
class_name Player3D

# <========================== Variables ====================================>


# <========================== Functions ========================================>


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		dash()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	move()
	update_state()
	update_animation()
