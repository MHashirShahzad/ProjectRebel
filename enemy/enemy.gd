extends Entity3D
class_name EnemyBase3D



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	
	
	move()
	update_state()
	update_animation()
