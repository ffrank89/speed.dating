extends Node
## Music (autoload): plays the game's music, fading from one track to the next.
##
## Every track, and how they fade, is data/music.tres (a MusicLibrary). A scene says what
## plays there with a Music Cue (scenes/Music/MusicCue.tscn): drop one in and type a
## track's name. A scene without one keeps whatever is playing. Microgames make the music
## quieter while they play. Full guide: docs/guides/music.md
##
## From code:
##   Music.play("date")            # fades to the track named "date"
##   Music.play("date", 0.0)       # straight away
##   Music.stop()                  # fades out
##   Music.quieter(true)           # quieter (Microgame Quieter dB), quieter(false) = back

## Sent when a new track starts ("" = the music stopped).
signal track_changed(track_name: String)

## Every track and how they fade (data/music.tres).
@export var library: MusicLibrary

var _track_name := ""
var _track: MusicTrack
# The player that's playing now, and the one that fades in next.
var _active: AudioStreamPlayer
var _spare: AudioStreamPlayer
var _fade: Tween
var _quieter_tween: Tween
var _quieter_db := 0.0
# How far the fade is: the active player at 1, the one fading out at 0.
var _active_mix := 1.0
var _spare_mix := 0.0
var _spare_track: MusicTrack

@onready var _players: Array[AudioStreamPlayer] = [$PlayerA, $PlayerB]


func _ready() -> void:
	if not library:
		library = MusicLibrary.new()
	# The music keeps going while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_active = _players[0]
	_spare = _players[1]
	for player in _players:
		player.bus = library.bus if AudioServer.get_bus_index(library.bus) >= 0 else &"Master"
		player.finished.connect(_on_finished.bind(player))


## Fades to the track with this name (from data/music.tres → Tracks). `fade` = seconds;
## -1 = Fade Seconds. An empty name stops the music. The same track (or another name for
## the same file) keeps playing without starting over.
func play(track_name: String, fade := -1.0) -> void:
	if track_name.is_empty():
		stop(fade)
		return
	var next := library.track(track_name)
	if not next:
		return
	if _track and _track.stream == next.stream and _active.playing:
		_track_name = track_name
		_track = next
		_update_volumes()
		return
	_change_to(next, track_name, fade)


## Fades the music out. `fade` = seconds; -1 = Fade Seconds.
func stop(fade := -1.0) -> void:
	if not _track:
		return
	_change_to(null, "", fade)


## The name of the track playing now ("" = none).
func current_track() -> String:
	return _track_name


## On = the music gets quieter (Microgame Quieter dB), e.g. while a microgame plays.
## Off = back to normal.
func quieter(on: bool) -> void:
	if _quieter_tween:
		_quieter_tween.kill()
	_quieter_tween = create_tween()
	_quieter_tween.tween_method(_set_quieter, _quieter_db, library.microgame_quieter_db if on else 0.0,
		library.quieter_seconds)


func _change_to(next: MusicTrack, next_name: String, fade: float) -> void:
	var seconds := library.fade_seconds if fade < 0.0 else fade
	if _fade:
		_fade.kill()
	# The playing track becomes the one fading out; the other player takes the new one.
	var outgoing := _active
	var outgoing_track := _track
	_active = _spare
	_spare = outgoing
	_spare_track = outgoing_track
	_spare_mix = _active_mix
	_track = next
	_track_name = next_name
	_active.stop()
	_active_mix = 0.0
	if next:
		_set_loop(next)
		_active.stream = next.stream
	track_changed.emit(next_name)

	if seconds <= 0.0:
		_spare_mix = 0.0
		_spare.stop()
		_start_active(next, 1.0)
		return
	_fade = create_tween()
	if library.fade_out_first:
		_fade.tween_method(_set_spare_mix, _spare_mix, 0.0, seconds * 0.5)
		_fade.tween_callback(_spare.stop)
		_fade.tween_callback(_start_active.bind(next, 0.0))
		_fade.tween_method(_set_active_mix, 0.0, 1.0, seconds * 0.5)
	else:
		_start_active(next, 0.0)
		_fade.set_parallel()
		_fade.tween_method(_set_spare_mix, _spare_mix, 0.0, seconds)
		_fade.tween_method(_set_active_mix, 0.0, 1.0, seconds)
		_fade.chain().tween_callback(_spare.stop)


func _start_active(next: MusicTrack, mix: float) -> void:
	_active_mix = mix
	_update_volumes()
	if next:
		_active.play(next.start_at)


# Looping: the file's own loop when it can; with Loop Early Seconds, by hand (_process).
func _set_loop(next: MusicTrack) -> void:
	var stream := next.stream
	var by_file := next.loop and next.loop_early_seconds <= 0.0
	if "loop" in stream:
		stream.set("loop", by_file)
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if by_file else AudioStreamWAV.LOOP_DISABLED


func _process(_delta: float) -> void:
	if not _track or not _track.loop or _track.loop_early_seconds <= 0.0 or not _active.playing:
		return
	var length := _active.stream.get_length()
	if length > _track.loop_early_seconds and _active.get_playback_position() >= length - _track.loop_early_seconds:
		_active.play(_track.start_at)


# A track that ended by itself (no loop in the file): start it again if it loops.
func _on_finished(player: AudioStreamPlayer) -> void:
	if player == _active and _track and _track.loop:
		player.play(_track.start_at)


func _set_active_mix(mix: float) -> void:
	_active_mix = mix
	_update_volumes()


func _set_spare_mix(mix: float) -> void:
	_spare_mix = mix
	_update_volumes()


func _set_quieter(db: float) -> void:
	_quieter_db = db
	_update_volumes()


# Each player's volume: the fade (as a 0-1 mix), the track's own volume, the music's
# Volume, and how much quieter it is now.
func _update_volumes() -> void:
	_active.volume_db = _volume_for(_track, _active_mix)
	_spare.volume_db = _volume_for(_spare_track, _spare_mix)


func _volume_for(track: MusicTrack, mix: float) -> float:
	var own := track.volume_db if track else 0.0
	return linear_to_db(maxf(mix, 0.0001)) + own + library.volume_db + _quieter_db
