extends Node2D

func _ready():
	# Connect button to each function
	$yes_button.pressed.connect(_on_yes_pressed)
	$no_button.pressed.connect(_on_no_pressed)

func _on_yes_pressed():

	Engine.time_scale = 1.0
	
	get_tree().paused = false
	
	get_tree().reload_current_scene()

func _on_no_pressed():
	get_tree().quit() 
