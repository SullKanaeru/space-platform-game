extends Area2D

# Hapus signal player_died, kita panggil langsung saja biar pasti jalan
# signal player_died 

func _on_body_entered(body: Node2D) -> void:
	# Cek apakah body yang nabrak punya fungsi "die" (artinya itu Player)
	if body.has_method("die"):
		# Panggil fungsi die() di script player secara langsung
		body.die()
