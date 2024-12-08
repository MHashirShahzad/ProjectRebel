extends State
class_name  StateWalking

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var ani_player: AnimationPlayer = $"../../AniPlayer"


func enter():
	ani_player.play("walking")

func exit():
	pass
	
func update(delta : float):
	pass
