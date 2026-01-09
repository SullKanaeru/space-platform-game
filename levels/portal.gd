extends Area2D

signal player_entered_portal

@onready var anim = $AnimatedSprite2D
var is_open = false

func _ready():
	anim.play("deactivated_portal")
	is_open = false
	
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)

func unlock_portal():
	anim.play("transition_portal")

func _on_animation_finished():
	if anim.animation == "transition_portal":
		anim.play("activated_portal")
		is_open = true

func _on_body_entered(body: Node2D):
	# Pastikan yang masuk Player DAN portal sudah terbuka
	if body.name == "Player" and is_open:
		# Panggil fungsi animasi transisi
		_start_portal_sequence(body)

# Fungsi baru untuk menangani logika "disedot"
func _start_portal_sequence(player):
	print("Player masuk portal! Memulai sekuens...")
	
	# 1. Matikan kontrol Player
	# Kita stop fungsi _physics_process di script player agar dia tidak bisa gerak/loncat lagi
	player.set_physics_process(false)
	
	# Opsional: Matikan collision shape player biar aman dari gangguan luar saat animasi
	# player.find_child("CollisionShape2D").call_deferred("set_disabled", true)
	
	# 2. Buat Tween untuk efek visual "Masuk Portal"
	var tween = create_tween()
	tween.set_parallel(true) # Jalankan animasi secara bersamaan
	
	# A. Tarik player ke posisi tengah portal (selama 1 detik)
	tween.tween_property(player, "global_position", global_position, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	# B. Kecilkan player jadi 0 (seperti menghilang ke dalam)
	tween.tween_property(player, "scale", Vector2.ZERO, 1.0)
	
	# C. Putar player (opsional, biar keren kayak disedot lubang hitam)
	tween.tween_property(player, "rotation_degrees", 360.0, 1.0)
	
	# D. Fade out (transparan)
	tween.tween_property(player, "modulate:a", 0.0, 1.0)
	
	# 3. Tunggu animasi selesai
	await tween.finished
	
	# 4. Tambahan Delay sesuai request (misal 0.5 detik hening sejenak sebelum menu muncul)
	await get_tree().create_timer(0.5).timeout
	
	# 5. Baru lapor ke Level (yang akhirnya akan pause game)
	player_entered_portal.emit()
