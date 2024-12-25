extends CharacterBody3D
class_name Entity3D
# <========================== Signals ====================================>
signal state_changed

signal input_enabled
signal input_disabled

signal movement_enabled
signal movement_disabled

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
@onready var coll_shape: CollisionShape3D = $CollisionShape3D
@onready var land_vfx: Marker3D = $LandVFX
@onready var fsm: Node = $FSM


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
		is_action_enabled = value

var is_movement_enabled : bool = true:
	set(value):
		if value == true:
			movement_enabled.emit()
		else:
			movement_disabled.emit()
		is_movement_enabled = value

var facing: Vector3:
	get: return -coll_shape.global_transform.basis.x

var current_state : STATE = STATE.IDLE

var can_jump : bool = true

var health : float = 100

		
enum STATE{
	IDLE,
	WALKING,
	JUMP_ANTICIPATION,
	JUMPING,
	FALLING,
	TURNING_AROUND,
	DASHING,
	ATTACKING_1,
	ATTACKING_2
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

# rotate 
func _can_turn_around(factor : Vector2) -> bool:
	if coll_shape.rotation_degrees.y == 180:
		if factor.x < 0: # if player is inputing right 
			coll_shape.rotation_degrees.y = 0
			return true
	else:
		if factor.x > 0: # if player is inputing left 
			coll_shape.rotation_degrees.y = 180
			return true
	return false
	
func _move() -> void:
	
	direction = (global_basis * Vector3(wish_dir.x, 0, wish_dir.y)).normalized()
	if direction:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction)
		
	var was_on_floor := is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		_just_left_ground()
		
	if is_on_floor() and !was_on_floor:
		_just_landed()

func _jump() -> void:

	jump_count += 1
	can_jump = false
	
	InputBuffer._invalidate_action("jump")
	# State managing
	current_state = STATE.JUMP_ANTICIPATION
	await ani_player.animation_finished
	stretch()
	current_state = STATE.JUMPING
	velocity.y = jump_velocity

func _update_animation():
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
		STATE.ATTACKING_1:
			ani_player.play("attack1")
	
func _update_state() -> void:
	var vel_round := velocity.round()
	if is_on_floor():
		_ground_state(vel_round)
	else:
		_air_state(vel_round)
	
func _ground_state(vel_round : Vector3) -> void:
	if current_state == STATE.JUMP_ANTICIPATION: #|| current_state == STATE.ATTACKING_1:
		return
	if current_state == STATE.DASHING:
		_can_turn_around(Vector2(vel_round.x, vel_round.y)) # if 
		return
	if current_state == STATE.ATTACKING_1:
		_can_turn_around(wish_dir)
		return
	
	if _can_turn_around(wish_dir):
		is_action_enabled = false
		current_state = STATE.TURNING_AROUND
		await ani_player.animation_finished
		is_action_enabled = true
	
	# If approximately not moving
	elif ! is_zero_approx(wish_dir.x)  || ! is_zero_approx(wish_dir.y):
		current_state = STATE.WALKING
	else:
		current_state = STATE.IDLE
		
func _air_state(vel_round : Vector3) -> void:
	if current_state == STATE.DASHING:
		return
	_can_turn_around(wish_dir)
	if vel_round.y > 1:
		current_state = STATE.JUMPING
	elif vel_round.y < -1:
		current_state = STATE.JUMPING # falling

func _dash() -> void:
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
	await ani_player.animation_finished
	current_state = STATE.IDLE
	is_action_enabled = true
	
func _attack() -> void:
	if !is_on_floor():
		return
	if current_state == STATE.ATTACKING_1:
		print("POYO")
		return
	
	InputBuffer._invalidate_action("attack")
	
	is_action_enabled = false
	current_state = STATE.ATTACKING_1
	await ani_player.animation_finished  # Causes bugs when ani is switched before finishind
	current_state = STATE.IDLE
	is_action_enabled = true

func _just_landed() -> void:
	jump_count = 0 # reset jumps
	if current_state == STATE.DASHING: # wave dash
		self.velocity = self.velocity * 1.2
	VFXManager.spawn_vfx(land_vfx, VFXManager.LAND_VFX)
	squash()
	
## Also used for coyote timer
func _just_left_ground() -> void:
	if jump_count != 0:
		return
	# Coyote time
	can_jump = true
	await get_tree().create_timer(.2).timeout
	can_jump = false

func _on_hit(damage : float) -> void:
	health -= damage
	print(self.name, " : ",health)
	
	if health <= 0:
		print("DEAD")

func _recieve_knockback(kb_dir : Vector3, strength : float) -> void:

	
	var knock_back = kb_dir * strength
	velocity += knock_back

func stretch() -> void:
	const STRETCHED_SIZE : Vector3 = Vector3(.7,1.3,1)
	sprite_3d.scale = STRETCHED_SIZE
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(sprite_3d,"scale", Vector3(1,1,1),.1)
	await tween.finished
	tween.kill()
	
func squash() -> void:
	const SQUASHED_SIZE : Vector3 = Vector3(1.3,0.7,1)
	sprite_3d.scale = SQUASHED_SIZE
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(sprite_3d, "scale", Vector3(1,1,1),.1)
	await tween.finished
	tween.kill()

func _screw_state(duration : float) -> void:
	var cur_pos : Vector3 = sprite_3d.position
	var timer : Timer = Timer.new()
	timer.wait_time = duration
	
	self.add_child(timer)
	timer.start()
	
	self.remove_child(timer)
	timer.queue_free()
	while(timer):
		await get_tree().create_timer(0.01).timeout
		sprite_3d.position.x = cur_pos.x + randi_range(-0.05,0.05)
		sprite_3d.position.y = cur_pos.y + randi_range(-0.05,0.05)
	print("TIMER DED")
	await get_tree().create_timer(duration).timeout
	sprite_3d.position = cur_pos
