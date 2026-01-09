extends Node2D

signal retry_pressed

func _ready():
	# Connect button to each function
	$yes_button.pressed.connect(_on_yes_pressed)
	$no_button.pressed.connect(_on_no_pressed)

func _on_yes_pressed():
	retry_pressed.emit()

func _on_no_pressed():
	get_tree().quit() 
