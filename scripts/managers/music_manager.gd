extends Node

# Single audio player for music
var music_player: AudioStreamPlayer

# Maps scene paths to music tracks
var scene_music_map = {
	"res://scenes/Dates/FirstDate/FirstDateTest.tscn": "res://assets/audio/loops/second ss free loop.ogg",
	"res://scenes/Dates/Date/Date.tscn": "res://assets/audio/loops/second ss free loop.ogg",
	"res://scenes/Calendar/calendar.tscn": "res://assets/audio/loops/second ss free loop.ogg",
	"res://scenes/Tinder/Screen.tscn": "res://assets/audio/loops/(FREE) 2hollis  Snow Strippers type beat keflavik.mp3"
}

## SFX dictionary (can be populated as needed)
#var sound_effects = {}
#
## Tracking variables
#var current_track_path = ""
#var current_scene_path = ""
#
## Early loop settings
#var loop_early_threshold: float = 1.1 # Number of seconds before end to restart
#var track_durations = {}  # Cache for track durations
#
#func _ready():
	## Set up audio player
	#music_player = AudioStreamPlayer.new()
	#music_player.bus = "Music"
	#add_child(music_player)
	#
	## Manual looping signal
	#music_player.finished.connect(_on_music_finished)
	#
	## Scene change detection
	#var timer = Timer.new()
	#timer.wait_time = 0.5
	#timer.autostart = true
	#timer.timeout.connect(_check_scene_change)
	#add_child(timer)
	#get_tree().root.connect("ready", _check_scene_change)
	#
	## Enable process for early loop detection
	#set_process(true)
	#
	#print("SimpleLoopingManager initialized")
#
#func _on_music_finished():
	#print("Music finished - manually restarting")
	#if music_player.stream:
		#music_player.play()
#
#func _process(_delta):
	## Check for early looping
	#if music_player.playing and music_player.stream:
		#var position = music_player.get_playback_position()
		#
		## If we have this track's duration cached
		#if current_track_path in track_durations:
			#var effective_duration = track_durations[current_track_path]
			#
			## If we're near the end, restart
			#if position >= effective_duration:
				#print("Looping early at: ", position, " seconds")
				#music_player.play(0)  # Restart from beginning
		#
		## Otherwise, if we're very close to the end based on stream length
		#elif position > 0 and music_player.stream.get_length() > 0:
			#var length = music_player.stream.get_length()
			#if position >= (length - loop_early_threshold):
				#print("Approaching end of track without cached duration, looping early")
				#music_player.play(0)
#
#func _check_scene_change():
	#if get_tree().current_scene:
		#var new_scene_path = get_tree().current_scene.scene_file_path
		#if new_scene_path != current_scene_path:
			#current_scene_path = new_scene_path
			#print("Scene changed to: ", new_scene_path)
			#
			#if scene_music_map.has(new_scene_path):
				#var music_path = scene_music_map[new_scene_path]
				#if current_track_path != music_path:
					#play_music(music_path)
#
#func play_music(track_path):
	## Skip if same track already playing
	#if track_path == current_track_path and music_player.playing:
		#return
		#
	#current_track_path = track_path
	#print("Playing music: ", track_path)
	#
	## Load the audio file
	#var stream = load(track_path)
	#if not stream:
		#print("ERROR: Couldn't load audio: ", track_path)
		#return
	#
	## Calculate and store effective duration
	#if not track_durations.has(track_path):
		#var full_duration = stream.get_length()
		#var effective_duration = max(0.1, full_duration - loop_early_threshold)
		#track_durations[track_path] = effective_duration
		#print("Track duration: ", full_duration, ", will loop at: ", effective_duration)
	#
	## Set the stream and play
	#music_player.stream = stream
	##music_player.play()
#
## Simple SFX player
#func play_sfx(sfx_name):
	#if sound_effects.has(sfx_name):
		#var sfx_path = sound_effects[sfx_name]
		#var sfx_player = AudioStreamPlayer.new()
		#sfx_player.bus = "SFX"
		#
		#var stream = load(sfx_path)
		#if stream:
			#sfx_player.stream = stream
			#add_child(sfx_player)
			#sfx_player.play()
			#
			## Auto-cleanup
			#sfx_player.finished.connect(func(): sfx_player.queue_free())
		#else:
			#sfx_player.queue_free()
			#print("ERROR: Couldn't load SFX: ", sfx_path)
#
## Utility methods
#func stop_music():
	#music_player.stop()
	#current_track_path = ""
#
#func set_music_volume(volume_db):
	#music_player.volume_db = volume_db
#
#func is_music_playing():
	#return music_player.playing
#
#func set_loop_early_threshold(seconds):
	#loop_early_threshold = seconds
	## Clear cached durations to force recalculation
	#track_durations.clear()
