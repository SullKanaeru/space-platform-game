extends Node2D

# Referensi ke node suara kalah
@onready var game_over_sound = $GameOverSound 

func _ready() -> void:
	new_game()
	
	# Setup signal Player & Level (sama seperti sebelumnya)
	var player = $LevelRoot/Player 
	if player:
		player.player_has_died.connect(game_over)
		
	var level = $LevelRoot
	if level:
		level.level_finished.connect(game_win)

func new_game() -> void:
	$GameOver.hide()
	$GameOver.modulate.a = 1.0 
	get_tree().paused = false 

func trigger_game_over_sequence(title_text: String):
	if $GameOver/Label:
		$GameOver/Label.text = title_text
	
	var game_over_ui = $GameOver
	game_over_ui.modulate.a = 0.0
	game_over_ui.show()
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	get_tree().paused = true
	
	tween.tween_property(game_over_ui, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE)

# --- FUNGSI KALAH (Diupdate) ---
func game_over() -> void:
	# 1. Mainkan suara kalah
	game_over_sound.play()
	
	# 2. Opsional: Matikan musik level pelan-pelan (Panggil fungsi di LevelRoot)
	# Pastikan script LevelRoot punya fungsi 'stop_bgm_fade_out' yang kita buat sebelumnya
	if $LevelRoot.has_method("stop_bgm_fade_out"):
		$LevelRoot.stop_bgm_fade_out()
	
	# 3. Jalankan urutan UI
	trigger_game_over_sequence("GAME OVER")

# --- FUNGSI MENANG ---
func game_win() -> void:
	# Kalau mau ada suara menang, bisa ditambah di sini juga logika serupa
	trigger_game_over_sequence("YOU WIN!")
