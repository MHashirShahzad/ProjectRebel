@tool
extends Node
class_name HitBoxManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func create_hitbox(
	shape : Shape3D,
	position : Vector3
):
	print("poyo")
	var hit_box = HitBox.new()
	var coll_shape = ColoredCollisionShape3D.new()
	coll_shape.shape = SphereShape3D.new()
	coll_shape._color = Color.RED
	hit_box.add_child(coll_shape)
	hit_box.global_position = position
	self.add_child(hit_box)
