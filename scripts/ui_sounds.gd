extends Node

@export var root_path : NodePath

@onready var sounds = {
	&"SFX_menu_accept" : AudioStreamPlayer.new(),
	&"sfx_menu_hover" : AudioStreamPlayer.new()
	}


func _ready() -> void:
	assert(root_path != null, "Empty root Path for UI sound!")

	for i in sounds.keys():
		sounds[i].stream = load("res://assets/sounds/" + str(i) + ".wav")
		sounds[i].bus = &"UI"
		add_child(sounds[i])

	install_sounds(get_node(root_path))


func install_sounds(node: Node) -> void:
	for i in node.get_children():
		if i is TextureButton:
			i.mouse_entered.connect( func(): ui_sfx_play(&"sfx_menu_hover"))
			i.pressed.connect( func(): ui_sfx_play(&"SFX_menu_accept"))	

		install_sounds(i)


func ui_sfx_play(sound: StringName) -> void:
	sounds[sound].play()
