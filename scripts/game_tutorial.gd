extends Node2D

var is_closing = false

func _ready():
	# 1. Pastikan script ini kebal pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. Pastikan gambar di paling depan
	z_index = 100 
	
	print("--- [DEBUG] Tutorial Dimuat. Menunggu Main selesai... ---")
	
	# 3. SOLUSI FIX: Tunggu 1 Frame
	# Ini memberi waktu agar main.gd selesai menjalankan 'new_game()'
	await get_tree().process_frame
	
	# 4. Setelah Main selesai reset, baru kita PAUSE lagi
	get_tree().paused = true
	print("--- [DEBUG] Game DIPAUSE oleh Tutorial ---")

# Kita kembali pakai _input karena lebih presisi untuk "Sekali Klik"
func _input(event):
	if is_closing:
		return
	
	# Deteksi Klik Kiri Mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("--- [DEBUG] 2. Klik Mouse Terdeteksi! ---")
		close_tutorial()
		
	# Deteksi Tombol Spasi / Enter (Jaga-jaga kalau mouse error)
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		print("--- [DEBUG] 2. Tombol Keyboard Terdeteksi! ---")
		close_tutorial()

func close_tutorial():
	is_closing = true
	print("--- [DEBUG] 3. Menutup Tutorial... Unpausing Game. ---")
	
	# Unpause
	get_tree().paused = false
	
	# Animasi Fade Out Manual (Iterasi semua anak)
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Memudarkan Root (Node2D) langsung
	# Jika ini gagal, berarti ada yang aneh dengan rendering Godot-nya
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	print("--- [DEBUG] 4. Animasi Selesai. Menghapus Node. ---")
	queue_free()
