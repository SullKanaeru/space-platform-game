extends CharacterBody2D

const SPEED = 300.0
const GRAVITY_SCALE = 3.0 

var gravity_direction = 1
var alive = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Gravitasi selalu jalan (PENTING: agar efek terpental terlihat natural melengkung)
	velocity += get_gravity() * gravity_direction * GRAVITY_SCALE * delta

	# --- LOGIKA MATI ---
	if not alive:
		move_and_slide() # Player tetap bergerak sesuai gaya dorong (knockback)
		return # Stop, jangan terima input lagi
	# -------------------

	# Input Lompat/Flip
	if Input.is_action_just_pressed("jump") and is_on_floor():
		flip_gravity()

	# Input Gerak Kiri/Kanan
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	move_and_slide()

func flip_gravity():
	gravity_direction *= -1
	up_direction = Vector2(0, -1) * gravity_direction
	velocity.y = 0 

func update_animation(direction):
	# (Kode animasi sama seperti sebelumnya)
	if not is_on_floor():
		animated_sprite.play("jump")
	else:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if gravity_direction == -1:
		animated_sprite.flip_v = true
	else:
		animated_sprite.flip_v = false

func die() -> void:
	# Cek agar fungsi ini tidak dipanggil berkali-kali
	if not alive:
		return
	
	alive = false
	
	# 1. Mainkan Animasi Mati
	animated_sprite.play("die")
	
	# 2. Efek Slow Motion (0.5 artinya setengah kecepatan normal)
	Engine.time_scale = 0.5
	
	# 3. Efek Terpental (Knockback)
	# Kita lempar ke belakang (negatif x) dan ke atas (negatif y relatif thdp gravitasi)
	# Angka 200 dan 400 bisa diubah sesuai selera kekuatan pentalan
	var knockback_dir_y = -1 * gravity_direction # Selalu berlawanan dengan arah gravitasi
	velocity = Vector2(-200, 400 * knockback_dir_y)
	
	# 4. Efek Berkedip & Menghilang (Menggunakan Tween)
	var tween = create_tween()
	
	# Loop berkedip (modulate alpha dari 1 ke 0.2) sebanyak 6 kali
	for i in range(6):
		tween.tween_property(self, "modulate:a", 0.2, 0.1) # Transparan
		tween.tween_property(self, "modulate:a", 1.0, 0.1) # Muncul lagi
	
	# Setelah berkedip, hilangkan pelan-pelan
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	
	# Hapus karakter dan kembalikan kecepatan waktu normal setelah selesai
	tween.tween_callback(finish_death)

func finish_death():
	Engine.time_scale = 1.0 
	
	# 2. Lapor ke Main dulu sebelum menghilang
	emit_signal("death_sequence_finished")
	
	queue_free()
