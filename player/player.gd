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

var current_state : STATE:
	get: return current_state
enum STATE{
	IDLE,
	WALKING,
	JUMP_ANTICIPATION,
	JUMPING,
	FALLING,
	TURNING_AROUND
}

# <========================== Functions ========================================>

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		self.velocity.x = wish_dir.x * 10
		self.velocity.z = wish_dir.y * 10
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	move()
	update_state()
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
func jump():
	current_state = STATE.JUMP_ANTICIPATION
	await ani_player.animation_finished
	current_state = STATE.JUMPING
	velocity.y = jump_velocity

func update_animation():
	# if already playing turn around return
	if ani_player.get_current_animation() == "turn_around":
		return
	match current_state:
		STATE.TURNING_AROUND:
			ani_player.play("turn_around")
		STATE.WALKING:
			ani_player.play("walking")
		STATE.IDLE:
			ani_player.play("idle")
		STATE.JUMP_ANTICIPATION:
			ani_player.play("jump_anticipation")
		STATE.FALLING:
			ani_player.play("falling")
		STATE.JUMPING:
			ani_player.play("jumping")
		
func update_state():
	var vel_round := velocity.round()
	if is_on_floor():
		ground_state(vel_round)
	else:
		air_state(vel_round)
	print(current_state)
	
func ground_state(vel_round : Vector3):
	if current_state == STATE.JUMP_ANTICIPATION:
		return
	if can_flip_sprite(sprite_3d):
		current_state = STATE.TURNING_AROUND
	elif ! is_zero_approx(vel_round.x)  || ! is_zero_approx(vel_round.z):
		current_state = STATE.WALKING
	else:
		current_state = STATE.IDLE
		
func air_state(vel_round : Vector3):
	if vel_round.y > 1:
		current_state = STATE.JUMPING
	elif vel_round.y < -1:
		current_state = STATE.FALLING
