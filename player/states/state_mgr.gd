extends Node
class_name StateManager
# <========================== Variables ====================================>

var states : Dictionary = {}
@export var initial_state : State
var current_state : State

# <========================== Code ====================================>

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(old_state : State, new_state_name : String):
	if old_state != current_state: # if states dont match
		print("Invalid changing state from: ",
		 	old_state.name, " currently in: ", current_state.name
		)
		return
	
	var new_state = states.get(new_state_name.to_lower()) # get new state
	
	if !new_state: # if new state is null
		print("New State is empty")
		return
	
	if current_state: # exit
		current_state.exit()
	
	new_state.enter() # new state
	current_state = new_state
