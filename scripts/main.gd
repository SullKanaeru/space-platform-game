extends Node2D

func _ready() -> void:
	new_game()
	
	# 1. Setup Player Signal (Mati)
	var player = $LevelRoot/Player 
	if player:
		player.player_has_died.connect(game_over)
		
	# 2. BARU: Setup Level Signal (Menang/Selesai)
	var level = $LevelRoot
	if level:
		# Hubungkan signal 'level_finished' dari script level.gd ke fungsi 'game_win'
		level.level_finished.connect(game_win)

func new_game() -> void:
	$GameOver.hide()
	get_tree().paused = false 

func game_over() -> void:
	$GameOver.show()
	# Opsional: Ubah teks label jadi "Game Over" (kalau sebelumnya diubah)
	if $GameOver/Label: $GameOver/Label.text = "GAME OVER"

# 3. BARU: Fungsi saat menang
func game_win() -> void:
	# Tampilkan menu yang sama (GameOver UI)
	$GameOver.show()
	
	# Opsional: Ubah teksnya biar beda dikit (misal: "LEVEL CLEARED!")
	# Pastikan kamu punya node Label di dalam scene GameOver
	if $GameOver/Label:
		$GameOver/Label.text = "YOU WIN!"
	
	# Pause game
	get_tree().paused = true
