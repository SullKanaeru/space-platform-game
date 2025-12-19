extends Area2D


func _on_body_entered(body: Node2D) -> void:
	# Check if the body is dead
	if body.has_method("die"):
		# Call die function from player's script
		body.die()
