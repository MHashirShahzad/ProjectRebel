extends CharacterBody3D
class_name Player3D

# <========================== Variables ====================================>

# <----------------------- Exports ---------------------->
@export var speed : float = 5
@export var friction : float = 0.04
@export var acceleration : float = 0.02
@export var jump_velocity : float = 4.5

# <----------------------- Onready ---------------------->
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var ani_player: AnimationPlayer = $AnimationPlayer

# <----------------------- Normal ---------------------->
var direction : Vector3
var wish_dir : Vector2
var facing: Vector3:
	get: return global_transform.basis.z


	
# <========================== Functions ========================================>

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		self.velocity.x = wish_dir.x * 10
		self.velocity.z = wish_dir.y * 10
		print(velocity)
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	move()
	update_animation()

func can_flip_sprite(sprite : Sprite3D) -> bool:
	if sprite.flip_h == true:
		if wish_dir.x < 0:
			sprite.flip_h = false
			return true
	else:
		if wish_dir.x > 0:
			sprite.flip_h = true
			return true
	return false
	
func move():
	wish_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(wish_dir.x, 0, wish_dir.y)).normalized()
	if direction:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction)
	move_and_slide()

func update_animation():
	var vel_round := velocity.round()
	
	# if already playing turn around return
	if ani_player.get_current_animation() == "turn_around":
		return
		
	if can_flip_sprite(sprite_3d):
		ani_player.play("turn_around")
	elif ! is_zero_approx(vel_round.x)  || ! is_zero_approx(vel_round.z):
		ani_player.play("move")
	else:
		ani_player.play("idle")
	
