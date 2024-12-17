extends Area3D
class_name HitBox

@export var damage : float = 2
@export var knock_back_value : int = 10
@export var offset : int = 20
@export var hit_stop : float = .2
@export var screw_state : float = .2
@export var self_stun : float = .1
@export var player_speed : float = .25
@export var to_ignore : MasterCharacter3D

var direction : Vector3
var kb_direction : Vector3
 

func _init() -> void:
	collision_layer = 32
	collision_mask = 0
