extends CharacterBody3D
class_name Player3D

# <========================== Variables ====================================>

# <----------------------- Exports ---------------------->
@export var speed : float = 10
@export var friction : float = 0.08
@export var acceleration : float = 0.04
@export var jump_velocity : float = 8
@export var dash_velocity : float = 15
# <----------------------- Onready ---------------------->
@onready var sprite_3d: Sprite3D = $Sprite3D

@onready var ani_player: AnimationPlayer = $AnimationPlayer
@onready var ani_tree: AnimationTree = $AnimationTree

@onready var coll_shape: CollisionShape3D = $CollisionShape3D
@onready var state_mgr: Node3D = $State_Mgr

# <----------------------- Normal ---------------------->
var direction : Vector3
var wish_dir : Vector2
var facing: Vector3:
	get: return global_transform.basis.z



# <========================== Functions ========================================>

func _ready() -> void:
	ani_tree.active = true
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
			
		if wish_dir == Vector2.ZERO:
			return
		self.velocity.x = wish_dir.x * dash_velocity
		self.velocity.z = wish_dir.y * dash_velocity
		
		await ani_player.animation_finished
		
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		jump()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	move()


func can_flip_sprite(factor) -> bool:
	# factor = wish direction
	
	#if sprite_3d.rotation_degrees.y == 180:
		#if factor.x < 0: # if sprite is flipped 
			#sprite_3d.rotation_degrees.y = 0
			#return true
	#else:
		#if factor.x > 0:
			#sprite_3d.rotation_degrees.y = 180
			#return true
	#return false
	
	if sprite_3d.flip_h == true:
		if factor.x < 0: # if sprite is flipped 
			sprite_3d.flip_h = false
			return true
	else:
		if factor.x > 0:
			sprite_3d.flip_h = true
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
	velocity.y = jump_velocity
