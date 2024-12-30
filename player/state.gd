extends Label3D
class_name StateLabel

@onready var player: Entity3D = $".."

func _process(delta: float) -> void:
	if !Debugger.debug_enabled:
		self.hide()
	else:
		self.show()
	
	var state = player.current_state
	var state_label = player.STATE.find_key(state)
	self.text = state_label
	
