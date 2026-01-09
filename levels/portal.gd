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

# Fungsi untuk menangani logika "disedot"
func _start_portal_sequence(player):
	print("Player masuk portal! Memulai sekuens...")
	
	# 1. Matikan kontrol Player (Input mati)
	player.set_physics_process(false)
	
	# 2. TAMBAHAN PENTING: Aktifkan mode kebal di Player
	if player.has_method("enter_portal_state"):
		player.enter_portal_state()
	
	# 3. Buat Tween untuk efek visual "Masuk Portal"
	var tween = create_tween()
	tween.set_parallel(true) # Jalankan animasi secara bersamaan
	
	# A. Tarik player ke posisi tengah portal (selama 1 detik)
	tween.tween_property(player, "global_position", global_position, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	# B. Kecilkan player jadi 0 (seperti menghilang ke dalam)
	tween.tween_property(player, "scale", Vector2.ZERO, 1.0)
	
	# C. Putar player
	tween.tween_property(player, "rotation_degrees", 360.0, 1.0)
	
	# D. Fade out (transparan)
	tween.tween_property(player, "modulate:a", 0.0, 1.0)
	
	# 4. Tunggu animasi selesai
	await tween.finished
	
	# 5. Tambahan Delay (hening sejenak)
	await get_tree().create_timer(0.5).timeout
	
	# 6. Lapor ke Level -> Main untuk memunculkan Win Screen
	player_entered_portal.emit()
