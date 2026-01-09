extends Node2D

# Untuk Level B, kosongkan path ini jika ini adalah level terakhir, 
# atau isi dengan level_c_1.tscn jika ada level selanjutnya.
@export_file("*.tscn") var next_level_scene: String = "" 

var total_shards_needed = 0
var current_shards = 0
var target_volume = -10.0

@onready var portal = $Portal
@onready var shards_container = $Shards
@onready var player = $Player
@onready var bgm = $AudioStreamPlayer2D

signal level_finished

func _ready():
	start_bgm_fade_in()
	
	# Menghitung total shard secara dinamis berdasarkan jumlah node di dalam container
	if shards_container:
		total_shards_needed = shards_container.get_child_count()
		for shard in shards_container.get_children():
			if shard.has_signal("shard_collected"):
				shard.shard_collected.connect(_on_shard_collected)
	
	# Menghubungkan sinyal ketika player masuk ke portal
	if portal:
		# Pastikan sinyal player_entered_portal sudah ada di script portal kamu
		portal.player_entered_portal.connect(_on_portal_entered)

func _on_shard_collected():
	current_shards += 1
	# Memanggil fungsi UI angka pada player jika tersedia
	if player and player.has_method("show_shard_number"):
		player.show_shard_number(current_shards)

	# Jika semua shard terkumpul, buka portal
	if current_shards >= total_shards_needed:
		if portal.has_method("unlock_portal"):
			portal.unlock_portal()

func _on_portal_entered():
	# Memancarkan sinyal selesai level ke main.gd
	level_finished.emit()

func start_bgm_fade_in():
	if bgm:
		bgm.volume_db = -20.0
		bgm.play()
		# Efek suara membesar perlahan saat level dimulai
		create_tween().tween_property(bgm, "volume_db", target_volume, 3.0)

func stop_bgm_fade_out():
	if bgm:
		var tween = create_tween()
		# Efek suara mengecil perlahan saat level selesai
		tween.tween_property(bgm, "volume_db", -80.0, 0.5)
		tween.tween_callback(bgm.stop)
