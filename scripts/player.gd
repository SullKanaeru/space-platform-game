extends CharacterBody2D

const SPEED = 200.0
const GRAVITY_SCALE = 5

var gravity_direction = 1
var alive = true
# Variabel baru agar player kebal saat masuk portal
var is_entering_portal = false 

signal player_has_died

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var naik_sound: AudioStreamPlayer2D = $NaikSfx
@onready var turun_sound: AudioStreamPlayer2D = $TurunSfx
@onready var die_sound: AudioStreamPlayer2D = $DieSfx
@onready var shard_counter_label = $ShardCounter

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"): # Tekan Spasi untuk cek
		print("--- CEK STATUS PLAYER ---")
		print("Apakah Game Paused? ", get_tree().paused)
		print("Process Mode Player (0=Inherit, 1=Pausable, 3=Always): ", process_mode)
		print("Bisakah Player Memproses? ", can_process())
		print("-------------------------")
	velocity += get_gravity() * gravity_direction * GRAVITY_SCALE * delta

	if not alive:
		move_and_slide()
		return 

	if is_on_floor():
		# Menggunakan action yang sudah didaftarkan (W atau Panah Atas)
		if Input.is_action_just_pressed("go_up"): 
			if gravity_direction == 1:
				flip_gravity()
				naik_sound.play()
				
		# Menggunakan action yang sudah didaftarkan (S atau Panah Bawah)
		elif Input.is_action_just_pressed("go_down"):
			if gravity_direction == -1:
				flip_gravity()
				turun_sound.play()
				
		# Logic Lompat (Spasi) tetap sama
		elif Input.is_action_just_pressed("jump"):
			flip_gravity()
			if gravity_direction == -1:
				naik_sound.play()
			else:
				turun_sound.play()
	
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
	# Cek tambahan: Jika sedang masuk portal, JANGAN mati.
	if not alive or is_entering_portal:
		return

	alive = false
	animated_sprite.play("die")
	Engine.time_scale = 0.5 

	var knockback_dir_y = -1 * gravity_direction 
	velocity = Vector2(-200, 400 * knockback_dir_y)
	
	die_sound.play()
	await get_tree().create_timer(0.5).timeout
	
	player_has_died.emit() 
	get_tree().paused = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Cek juga di sini agar tidak mati saat disedot keluar layar
	if not is_entering_portal:
		die()

# --- FUNGSI BARU: MODE KEBAL SAAT MASUK PORTAL ---
func enter_portal_state():
	is_entering_portal = true
	# Matikan collision agar tidak kena duri/musuh saat animasi berjalan
	$CollisionShape2D.set_deferred("disabled", true)

# --- FUNGSI MENAMPILKAN ANGKA SHARD ---
func show_shard_number(number: int):
	if not shard_counter_label:
		return

	shard_counter_label.text = str(number)
	
	# Posisi label (sesuaikan offsetnya)
	shard_counter_label.position = Vector2(-150, -50) 
	
	shard_counter_label.modulate.a = 1.0 
	shard_counter_label.show()
	
	var tween = create_tween()
	tween.set_parallel(true) 
	
	tween.tween_property(shard_counter_label, "position", shard_counter_label.position + Vector2(0, -30), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(shard_counter_label, "modulate:a", 0.0, 1.0)
