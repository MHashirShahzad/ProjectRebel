extends Node

func _ready() -> void:
	Console.add_command("debug", debug, 0, 0, "Toggles Debug Overlay")
	Console.add_command(":d", debug, 0, 0, "Short for debug")
	
func debug():
	ColoredCollisionShape3D.debug()
	StateLabel.debug()
