@tool
extends AnimationPlayer 


func _ready():
	animation_started.connect(animation_started_func)

var EDITOR_PATH: String:
	get: return str(get_parent().get_path()) + "/"

var function_calls = []
func animation_started_func(dismiss):
#	print("animation_started_func(dismiss: %s)" % dismiss)
	var song_animation = get_animation(current_animation)
#	print("	%s" % song_animation)
	for track_index in song_animation.get_track_count():
		
		if song_animation.track_get_type(track_index) == Animation.TYPE_METHOD:
			var path = EDITOR_PATH + str(song_animation.track_get_path(track_index))
#			print("		track_index: %s" % track_index)
#			print("		path: %s" % path)
			var track_key_count = song_animation.track_get_key_count(track_index)
			for key_index in track_key_count:
				var time = song_animation.track_get_key_time(track_index, key_index)
				if time >= current_animation_position:
#					print("			key_index: %s" % key_index)
					var _name = song_animation.method_track_get_name(track_index, key_index)
					var params = song_animation.method_track_get_name(track_index, key_index)
#					print("				name: %s" % _name)
#					print("				time: %s" % time)
					function_calls.append({
						"path": path,
						"name": _name,
						"time": time
					})
				
				else:
					pass
#					print('			...')
		else:
			pass
#			print("		...")

func _process(delta):
	
	if is_playing():
		var remove_these_function_calls = []
		print(function_calls, "Y")
		for i in function_calls.size():
			var function_call = function_calls[i]
			if function_call.time <= current_animation_position:
#				print("AnimationPlayer is calling the function of another node.")
				#print("	path: %s" % function_call.path)
#				print("	name: %s" % function_call.name)
				var node = get_node(function_call.path)
				function_call
				node.call(function_call.name, SphereShape3D.new(), Vector3(0,5,0))
				remove_these_function_calls.append(i)
		
		for index in remove_these_function_calls:
#			print("AnimationPlayer is removing function call from its queue.")
			function_calls.remove_at(index)
