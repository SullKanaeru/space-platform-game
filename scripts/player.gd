extends CharacterBody2D

const SPEED = 200.0
const GRAVITY_SCALE = 5

var gravity_direction = 1
var alive = true
var is_entering_portal = false 

signal player_has_died

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var naik_sound: AudioStreamPlayer2D = $NaikSfx
@onready var turun_sound: AudioStreamPlayer2D = $TurunSfx
@onready var die_sound: AudioStreamPlayer2D = $DieSfx
@onready var shard_counter_label = $ShardCounter

func _ready() -> void:
	# SOLUSI 1: Reset Engine dan State setiap kali player lahir kembali
	Engine.time_scale = 1.0
	alive = true
	is_entering_portal = false
	velocity = Vector2.ZERO
	# Pastikan collision aktif kembali saat respawn
	$CollisionShape2D.disabled = false 

func _physics_process(delta: float) -> void:
	# SOLUSI 2: Gunakan delta secara konsisten pada gravitasi
	velocity += get_gravity() * gravity_direction * GRAVITY_SCALE * delta

	if not alive:
		# Saat mati, biarkan sisa momentum berjalan tanpa input
		move_and_slide()
		return 

	if is_on_floor():
		if Input.is_action_just_pressed("go_up"): 
			if gravity_direction == 1:
				flip_gravity()
				naik_sound.play()
				
		elif Input.is_action_just_pressed("go_down"):
			if gravity_direction == -1:
				flip_gravity()
				turun_sound.play()
				
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
		# SOLUSI 3: Gunakan move_toward agar pengereman tidak terpengaruh lag
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	
	# move_and_slide() di Godot 4 sudah otomatis menangani delta untuk posisi
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
	if not alive or is_entering_portal:
		return

	alive = false
	animated_sprite.play("die")
	
	# Memberikan efek slow motion saat mati
	Engine.time_scale = 0.5 

	var knockback_dir_y = -1 * gravity_direction 
	velocity = Vector2(-200, 400 * knockback_dir_y)
	
	die_sound.play()
	
	# Gunakan timer non-paused agar tetap berjalan meski game nanti di-pause
	var timer = get_tree().create_timer(0.5)
	await timer.timeout
	
	player_has_died.emit() 
	get_tree().paused = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not is_entering_portal:
		die()

func enter_portal_state():
	is_entering_portal = true
	$CollisionShape2D.set_deferred("disabled", true)

func show_shard_number(number: int):
	if not shard_counter_label:
		return

	shard_counter_label.text = str(number)
	shard_counter_label.position = Vector2(-150, -50) 
	shard_counter_label.modulate.a = 1.0 
	shard_counter_label.show()
	
	var tween = create_tween()
	tween.set_parallel(true) 
	tween.tween_property(shard_counter_label, "position", shard_counter_label.position + Vector2(0, -30), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(shard_counter_label, "modulate:a", 0.0, 1.0)
