extends CharacterBody2D

const SPEED = 300.0
const GRAVITY_SCALE = 3.0 

var gravity_direction = 1
var alive = true
signal player_has_died

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Gravitation logic
	velocity += get_gravity() * gravity_direction * GRAVITY_SCALE * delta

	# Character die logic
	if not alive:
		move_and_slide() # Knockback effect
		return 

	# Controller to jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		flip_gravity()

	# Controller to move
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	move_and_slide()

# Reversing the gravity
func flip_gravity():
	gravity_direction *= -1
	up_direction = Vector2(0, -1) * gravity_direction
	velocity.y = 0 

# Update animation after reversing gravity.
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
	if not alive:
		return

	alive = false
	animated_sprite.play("die")
	Engine.time_scale = 0.5 

	var knockback_dir_y = -1 * gravity_direction 
	velocity = Vector2(-200, 400 * knockback_dir_y)
	
	# Send signal to Main if the player is dead
	await get_tree().create_timer(0.5).timeout
	
	# Pause game
	get_tree().paused = true
	player_has_died.emit() 

# Handle game over when character exits screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()
