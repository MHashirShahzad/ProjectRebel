extends Label3D
class_name StateLabel

@onready var player: Player3D = $".."
static var debug_enabled : bool = false

func _process(delta: float) -> void:
	if !debug_enabled:
		self.hide()
	else:
		self.show()
	
	var state = player.current_state
	var state_label = player.STATE.find_key(state)
	self.text = state_label
	
## Reveses the debug enabled variable
static func debug():
	if debug_enabled:
		debug_enabled = false
	else:
		debug_enabled = true
