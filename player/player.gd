extends CharacterBody3D
class_name Player3D

# <========================== Variables ====================================>

var speed : float = 5.0
var jump_velocity : float = 4.5
var direction : Vector3

var facing: Vector3:
	get: return global_transform.basis.z
	
	
# <========================== Functions ========================================>

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		self.velocity = direction * 100
		print(direction)
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	flip_sprite($Sprite3D)
	move_and_slide()

func flip_sprite(sprite : Sprite3D):
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false
