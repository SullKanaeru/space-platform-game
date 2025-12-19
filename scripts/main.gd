extends Node2D

func _ready() -> void:
	# Call the new_game function every time the game starts.
	new_game()
	
	# Prepare signal
	var player = $LevelRoot/Player 
	
	# Connect signal
	if player:
		player.player_has_died.connect(game_over)

func new_game() -> void:
	$GameOver.hide()
	# Make sure the game is not paused when it starts.
	get_tree().paused = false 
	
func game_over() -> void:
	# Show gameover
	$GameOver.show()
