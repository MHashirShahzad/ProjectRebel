extends CharacterBody3D
class_name MasterCharacter3D
# <========================== Signals ====================================>
signal input_enabled
signal input_disabled
signal state_changed
# <========================== Variables ====================================>

# <----------------------- Exports ---------------------->
@export_group("Physics")
@export var speed : float = 10
@export var friction : float = 0.08
@export var acceleration : float = 0.04
@export var jump_velocity : float = 8
## X value is applied for velocity.x and velocity.z while y value is for air
@export var dash_velocity : Vector2 = Vector2(15, -1)
@export var max_jump_count : int = 1
# <----------------------- Onready ---------------------->
@onready var sprite_3d: Sprite3D = $CollisionShape3D/Sprite3D
@onready var ani_player: AnimationPlayer = $AniPlayer
@onready var ani_tree: AnimationTree = $AnimationTree
@onready var coll_shape: CollisionShape3D = $CollisionShape3D

# <----------------------- Normal ---------------------->
var jump_count : int = 0
var direction : Vector3
var wish_dir : Vector2

var is_action_enabled : bool = true:
	set(value):
		if value == true:
			input_enabled.emit
		else:
			input_disabled.emit

var facing: Vector3:
	get: return global_transform.basis.z
var current_state : STATE:
	get: return current_state

var can_jump : bool = true

enum STATE{
	IDLE,
	WALKING,
	JUMP_ANTICIPATION,
	JUMPING,
	FALLING,
	TURNING_AROUND,
	DASHING,
	ATTACKING_1
}

# <========================== Functions ========================================>

func _buffered_input(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass
	
func _process(delta: float) -> void:
	_buffered_input(delta)

func can_turn_around(factor : Vector2) -> bool:
	if coll_shape.rotation_degrees.y == 180:
		if factor.x < 0: # if player is inputing right 
			coll_shape.rotation_degrees.y = 0
			return true
	else:
		if factor.x > 0: # if player is inputing left 
			coll_shape.rotation_degrees.y = 180
			return true
	return false
	
func move() -> void:
	wish_dir = Input.get_vector("left", "right", "forward", "backward")
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
		
func jump() -> void:
	jump_count += 1
	can_jump = false
	
	InputBuffer._invalidate_action("jump")
	# State managing
	current_state = STATE.JUMP_ANTICIPATION
	await ani_player.animation_finished
	
	current_state = STATE.JUMPING
	velocity.y = jump_velocity

## DEPRECATED
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
		STATE.DASHING:
			ani_player.play("dash")
	
func update_state() -> void:
	var vel_round := velocity.round()
	if is_on_floor():
		ground_state(vel_round)
	else:
		air_state(vel_round)
	printraw("\rState: ", current_state)
	
func ground_state(vel_round : Vector3) -> void:
	if current_state == STATE.JUMP_ANTICIPATION: #|| current_state == STATE.ATTACKING_1:
		return
	if current_state == STATE.DASHING:
		can_turn_around(Vector2(vel_round.x, vel_round.y)) # if 
		return
	if current_state == STATE.ATTACKING_1:
		can_turn_around(wish_dir)
		return
	
	if can_turn_around(wish_dir):
		current_state = STATE.TURNING_AROUND
	elif ! is_zero_approx(wish_dir.x)  || ! is_zero_approx(wish_dir.y):
		current_state = STATE.WALKING
	else:
		current_state = STATE.IDLE
		
func air_state(vel_round : Vector3) -> void:
	if current_state == STATE.DASHING:
		return
	can_turn_around(wish_dir)
	if vel_round.y > 1:
		current_state = STATE.JUMPING
	elif vel_round.y < -1:
		current_state = STATE.JUMPING # falling

func dash() -> void:
	if current_state == STATE.DASHING or current_state == STATE.JUMP_ANTICIPATION:
		return
		
	if wish_dir == Vector2.ZERO:
		return

	# wish dir is vec2 so x and y
	self.velocity.x = wish_dir.x * dash_velocity.x
	self.velocity.z = wish_dir.y * dash_velocity.x
	# add downward velocity
	self.velocity.y = dash_velocity.y
	
	# invalidate the buffer
	InputBuffer._invalidate_action("dash")
	is_action_enabled = false
	current_state = STATE.DASHING
	await ani_tree.animation_finished
	current_state = STATE.IDLE
	is_action_enabled = true
	
func attack() -> void:
	if !is_on_floor():
		return
	
	InputBuffer._invalidate_action("attack")
	is_action_enabled = false
	current_state = STATE.ATTACKING_1
	await ani_tree.animation_finished  # Causes bugs when ani is switched before finishing
	print("ANi finished")
	current_state = STATE.IDLE
	is_action_enabled = true

func just_landed() -> void:
	jump_count = 0 # reset jumps
	if current_state == STATE.DASHING: # wave dash
		self.velocity = self.velocity * 1.2

## Also used for coyote timer
func just_left_ground() -> void:
	if jump_count != 0:
		return
	# Coyote time
	can_jump = true
	await get_tree().create_timer(.2).timeout
	can_jump = false
