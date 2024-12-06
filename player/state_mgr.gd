extends Node3D

@onready var anim_tree: AnimationTree = $"../AnimationTree"
@onready var player: Player3D = $".."

func _physics_process(delta: float) -> void:
	update_ani_params()

func update_ani_params():
	if player.velocity.x > 0 or player.velocity.y > 0:
		anim_tree.set("parameters/Locomotion/conditions/is_idle", false)
		anim_tree.set("parameters/Locomotion/conditions/is_walking", true)
	else:
		anim_tree.set("parameters/Locomotion/conditions/is_idle", true)
		anim_tree.set("parameters/Locomotion/conditions/is_walking", false)
