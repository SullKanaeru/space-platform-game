extends Node2D # Atau "extends Control" jika root node kamu tipe Control

# Signal ini akan ditangkap oleh Main.gd
signal next_level_pressed

func _ready():
	# Pastikan saat menu ini muncul, dia bisa menerima input mouse
	# (Meskipun sudah dihandle di main, tidak ada salahnya memastikan)
	pass

# Fungsi ini dijalankan saat tombol Continue ditekan
func _on_continue_button_pressed():
	print("Tombol Continue ditekan!")
	# Kirim sinyal ke Main.gd untuk pindah level
	next_level_pressed.emit()
