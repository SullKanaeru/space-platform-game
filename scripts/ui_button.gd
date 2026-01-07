extends Node


@onready var timer := $DelayTimer

func _on_play_pressed() -> void:
	await wait(0.6)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_exit_pressed() -> void:
	await wait(0.6)
	get_tree().quit()


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
