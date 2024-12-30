extends Area3D
class_name HitBox

@export var damage : float = 30
@export var kb_strength : float = 10
@export var hit_stop : float = .2
@export var self_stun : float = .1

@export var to_ignore : Entity3D

var collision_shape : CollisionShape3D

func _init() -> void:
	collision_layer = 32
	collision_mask = 0

func _ready() -> void:
	var child = self.get_child(0)
	if child is CollisionShape3D:
		collision_shape = child
