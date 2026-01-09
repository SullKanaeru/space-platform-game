extends Node2D

@export_file("*.tscn") var next_level_scene: String 

var total_shards_needed = 0
var current_shards = 0

@onready var shards_container = $Shards
@onready var portal = $Portal
@onready var bgm = $AudioStreamPlayer2D

signal level_finished

func _ready():
	# 1. Setup Audio Fade In
	if bgm:
		bgm.volume_db = -80
		bgm.play()
		create_tween().tween_property(bgm, "volume_db", 0, 2.0)
	
	# 2. Hitung Shard
	if shards_container:
		total_shards_needed = shards_container.get_child_count()
		for shard in shards_container.get_children():
			if shard.has_signal("shard_collected"):
				shard.shard_collected.connect(_on_shard_collected)
	
	# 3. Hubungkan Portal (berdasarkan image_2bea89.png)
	if portal and portal.has_signal("player_entered_portal"):
		portal.player_entered_portal.connect(_on_portal_entered)

func _on_shard_collected():
	current_shards += 1
	var player = find_child("Player", true, false)
	if player and player.has_method("show_shard_number"):
		player.show_shard_number(current_shards)
		
	if current_shards >= total_shards_needed:
		if portal and portal.has_method("unlock_portal"):
			portal.unlock_portal()

func _on_portal_entered():
	level_finished.emit()

func stop_bgm_fade_out():
	if bgm:
		var tween = create_tween()
		tween.tween_property(bgm, "volume_db", -80, 1.5)
		tween.tween_callback(bgm.stop)
