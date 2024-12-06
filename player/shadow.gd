extends Node3D

@onready var decal: Decal = $"."
@onready var shadow_cast: RayCast3D = $"../ShadowCast"
@onready var player: Player3D = $".."

@export var y_dist : float = 0.1

func _process(delta: float) -> void:
	#if player.is_on_floor():
		#return
	if shadow_cast.is_colliding():
		self.modulate.a = 1
		self.global_position = shadow_cast.get_collision_point()
		self.global_position.y += y_dist
	else:
		self.modulate.a = 0
