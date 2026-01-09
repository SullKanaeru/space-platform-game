extends Node2D

@onready var game_over_ui = $GameOver
@onready var game_win_ui = $GameWin
@onready var game_over_sound = $GameOverSound
@onready var game_win_sound = $GameWinSound

var level_root: Node2D 
var first_level_path = "res://levels/level_a_1.tscn"
var next_level_path: String = ""
var current_level_path: String = ""
var is_game_finished = false

func _ready() -> void:
	var existing_level = get_node_or_null("LevelRoot")
	
	if existing_level:
		level_root = existing_level
		current_level_path = first_level_path
		connect_level_signals()
		new_game()
	else:
		load_level(first_level_path)
	
	if game_over_ui.has_signal("retry_pressed"):
		game_over_ui.retry_pressed.connect(retry_level)
	else:
		var retry_btn = game_over_ui.find_child("*Retry*", true, false)
		if retry_btn and retry_btn is BaseButton:
			retry_btn.pressed.connect(retry_level)
		
	if game_win_ui.has_signal("next_level_pressed"):
		game_win_ui.next_level_pressed.connect(load_next_level)
	else:
		var next_btn = game_win_ui.find_child("*Next*", true, false)
		if next_btn and next_btn is BaseButton:
			next_btn.pressed.connect(load_next_level)

func connect_level_signals():
	if not level_root: 
		return
	
	var player = level_root.find_child("Player", true, false)
	if player:
		if player.has_signal("player_has_died"):
			if player.player_has_died.is_connected(game_over):
				player.player_has_died.disconnect(game_over)
			player.player_has_died.connect(game_over)
	
	if level_root.has_signal("level_finished"):
		if level_root.level_finished.is_connected(game_win):
			level_root.level_finished.disconnect(game_win)
		level_root.level_finished.connect(game_win)

func new_game() -> void:
	is_game_finished = false
	get_tree().paused = false
	game_over_ui.hide()
	game_win_ui.hide()

func game_over() -> void:
	if is_game_finished: 
		return
	
	is_game_finished = true
	game_over_sound.play()
	_stop_level_audio()
	_show_ui_with_fade(game_over_ui)

func game_win() -> void:
	if is_game_finished: 
		return
	
	is_game_finished = true
	game_win_sound.play()
	
	if "next_level_scene" in level_root:
		next_level_path = level_root.next_level_scene
		
	_stop_level_audio()
	_show_ui_with_fade(game_win_ui)

func load_level(path: String):
	if path == "" or not ResourceLoader.exists(path):
		return

	get_tree().paused = false
	is_game_finished = false
	
	if level_root:
		level_root.queue_free()
		await get_tree().process_frame 
	
	var scene = load(path)
	var new_lvl = scene.instantiate()
	new_lvl.name = "LevelRoot"
	add_child(new_lvl)
	move_child(new_lvl, 0) 
	
	level_root = new_lvl
	current_level_path = path 
	
	connect_level_signals()
	new_game()

func retry_level():
	if current_level_path != "":
		load_level(current_level_path)
	else:
		load_level(first_level_path)

func load_next_level():
	if next_level_path != "" and ResourceLoader.exists(next_level_path):
		load_level(next_level_path)
	else:
		load_level(first_level_path)

func _stop_level_audio():
	if level_root and level_root.has_method("stop_bgm_fade_out"):
		level_root.stop_bgm_fade_out()

func _show_ui_with_fade(ui_node: Node2D):
	ui_node.show()
	ui_node.modulate.a = 0
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(ui_node, "modulate:a", 1.0, 0.5)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
