extends Node3D
const PLAYER = preload("res://player/player.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_left"):
		var player = PLAYER.instantiate()
		self.add_child(player)
		player.position.x = randi_range(-10, 10)
		player.position.y = 5
		player.position.z = randi_range(-10, 10)
		$Level/Camera.update_players()
