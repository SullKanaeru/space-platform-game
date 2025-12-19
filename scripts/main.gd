extends Node2D

func _ready() -> void:
	# Panggil fungsi setup game baru
	new_game()
	
	# CARI PLAYER DAN SAMBUNGKAN SIGNAL
	# Sesuaikan path ini dengan posisi Player kamu di Scene Tree
	# Jika Player ada di dalam LevelRoot langsung:
	var player = $LevelRoot/Player 
	
	# Sambungkan signal 'player_has_died' dari script player ke fungsi 'game_over' di sini
	if player:
		player.player_has_died.connect(game_over)

func new_game() -> void:
	$GameOver.hide()
	# Pastikan game tidak dalam kondisi pause saat mulai
	get_tree().paused = false 
	
func game_over() -> void:
	# Munculkan layar Game Over
	$GameOver.show()
