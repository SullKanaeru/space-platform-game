extends Node2D

@onready var game_over_ui = $GameOver
@onready var win_screen_ui = $GameWin
@onready var game_over_sound = $GameOverSound
@onready var game_win_sound = $GameWinSound
@onready var level_root = $LevelRoot

var next_level_path = "res://scenes/Level2.tscn"
var is_game_finished = false

func _ready() -> void:
	new_game()
	
	var player = level_root.get_node_or_null("Player")
	if player:
		player.player_has_died.connect(game_over)
	
	if level_root.has_signal("level_finished"):
		level_root.level_finished.connect(game_win)
	
	if win_screen_ui.has_signal("next_level_pressed"):
		win_screen_ui.next_level_pressed.connect(load_next_level)

func new_game() -> void:
	is_game_finished = false
	get_tree().paused = false 
	
	game_over_ui.hide()
	game_over_ui.modulate.a = 1.0 
	
	win_screen_ui.hide()
	win_screen_ui.modulate.a = 1.0

func game_over() -> void:
	if is_game_finished:
		return
		
	is_game_finished = true
	
	game_over_sound.play()
	
	if level_root.has_method("stop_bgm_fade_out"):
		level_root.stop_bgm_fade_out()
	
	_show_ui_with_fade(game_over_ui)
	
	var label = game_over_ui.get_node_or_null("Label")
	if label:
		label.text = "GAME OVER"

func game_win() -> void:
	if is_game_finished:
		return

	is_game_finished = true
	
	game_win_sound.play()
	
	if level_root.has_method("stop_bgm_fade_out"):
		level_root.stop_bgm_fade_out()
	
	_show_ui_with_fade(win_screen_ui)

func load_next_level():
	get_tree().paused = false
	
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		get_tree().reload_current_scene()

func _show_ui_with_fade(target_ui: CanvasItem):
	target_ui.modulate.a = 0.0
	target_ui.show()
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	tween.tween_property(target_ui, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
