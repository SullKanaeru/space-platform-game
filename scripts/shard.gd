extends Area2D

signal shard_collected

@onready var collectSfx = $CollectSfx

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Pass 'body' to the collect method so it can read the variable
		collect_shard(body)

func collect_shard(player):
	shard_collected.emit()
	collectSfx.play()
	# Turn off monitoring so it doesn't get triggered twice.
	call_deferred("set_monitoring", false)
	
	# Get gravity direction from Player script
	var grav_dir = player.gravity_direction
	
	# Determine the animation direction
	var anim_offset_y = -30 * grav_dir 
	
	# Setup Tween
	var tween = create_tween()
	tween.set_parallel(true) 
	
	# Animation of gravity adjusting position
	tween.tween_property(self, "position", position + Vector2(0, anim_offset_y), 0.5)
	
	# Fade out animation
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	
	# Delete after finished
	tween.chain().tween_callback(self.queue_free)
