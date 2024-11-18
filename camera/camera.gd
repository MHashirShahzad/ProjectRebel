extends Camera3D

@export var players : Array[Player3D]
@export var fixed_dist : Vector3 = Vector3(0, 5,20)
@export_range(-90, 0, 1, "degrees") var angle : float = -22
@export_range(0,1,0.1) var cam_speed : float = 0.1

func _ready() -> void:
	self.rotation_degrees.x = angle
	update_players()

func update_players() -> void:	
	var array = get_tree().get_nodes_in_group("players")
	for player in array:
		if !player in players:
			players.append(player)

func _process(delta: float) -> void:
	update_cam()
	get_input()
	
func get_input():
	if Input.is_action_pressed("cam_zoom_in"):
		fixed_dist.z += .5
	if Input.is_action_pressed("cam_zoom_out"):
		fixed_dist.z -= .5
	fixed_dist.z = clamp(fixed_dist.z, 10, 25)
	
func update_cam():
	var sum_pos : Vector3
	var prev_player = players[0]
	var largest_z : float = prev_player.position.z
	var largest_dist : float = -1
	
	for player in players:
		sum_pos += player.global_position
		
		# Set largest z value
		if player.position.z > largest_z:
			largest_z = player.position.z
		
		# get largest dist
		var dist = prev_player.position.distance_to(player.position)
		if dist > largest_dist:
			largest_dist = dist
	
	# Add some constants so that user can see the players
	var destined_pos : Vector3 = sum_pos / players.size()
	destined_pos.z = largest_z
	destined_pos += fixed_dist
	
	# Angele and pos
	self.rotation_degrees.x = angle
	self.global_position = lerp(global_position, destined_pos, cam_speed)
	
	print_rich(largest_z, largest_dist)
