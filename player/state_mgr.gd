extends AnimationTree

@onready var anim_tree: AnimationTree = $"."
@onready var player: Player3D = $".."

func _physics_process(delta: float) -> void:
	update_ani_params()

func update_ani_params():
	var vel_round := player.velocity.round()
	# is idle if x and z are 0
	anim_tree.set("parameters/Locomotion/conditions/is_idle", 
		is_zero_approx(vel_round.x)  and  is_zero_approx(vel_round.z)
	)
	# is walking if approximately both vel are not zero
	anim_tree.set("parameters/Locomotion/conditions/is_walking", 
		! is_zero_approx(vel_round.x)  || ! is_zero_approx(vel_round.z)
	)
	anim_tree.set("parameters/Locomotion/conditions/is_jumping", 
		Input.is_action_pressed("ui_accept") and player.is_on_floor()
	)
	anim_tree.set("parameters/Locomotion/conditions/is_on_ground", 
		player.is_on_floor()
	)
