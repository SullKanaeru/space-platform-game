extends Node2D # Sesuaikan dengan tipe node root GameOver kamu (bisa Control/CanvasLayer/Node2D)

func _ready():
	# Menghubungkan tombol ke fungsi (bisa juga via tab Node di editor)
	$yes_button.pressed.connect(_on_yes_pressed)
	$no_button.pressed.connect(_on_no_pressed)

func _on_yes_pressed():
	# 1. PENTING: Kembalikan kecepatan waktu ke normal
	# Karena di player.gd kamu set ke 0.5, kalau tidak direset game baru bakal slow motion.
	Engine.time_scale = 1.0
	
	# 2. Buka Pause
	get_tree().paused = false
	
	# 3. Reload Scene saat ini
	get_tree().reload_current_scene()

func _on_no_pressed():
	# Force close aplikasi
	get_tree().quit()
