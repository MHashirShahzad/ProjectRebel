extends Node

var debug_enabled : bool = false

func _ready() -> void:
	Console.add_command("debug", debug, 0, 0, "Toggles Debug Overlay")
	Console.add_command(":d", debug, 0, 0, "Short for debug")
	
func debug():
	if debug_enabled:
		debug_enabled = false
	else:
		debug_enabled = true
