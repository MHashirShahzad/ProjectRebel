extends Sprite3D
@onready var shadow_cast: RayCast3D = $"../ShadowCast"


func _process(delta: float) -> void:
	if shadow_cast.is_colliding():
		self.modulate.a = 1
		self.global_position = shadow_cast.get_collision_point()
		self.global_position.y += 0.01
	else:
		self.modulate.a = 0
