extends Label3D
@onready var player: Player3D = $".."

func _process(delta: float) -> void:
	var state = player.current_state
	var state_label = player.STATE.find_key(state)
	self.text = state_label
