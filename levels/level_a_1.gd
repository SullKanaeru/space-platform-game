extends Node2D

# Set variable
var total_shards_needed = 3
var current_shards = 0

# Fetch references
@onready var portal = $Portal 
@onready var shards_container = $Shards
@onready var player = $Player

@onready var bgm = $AudioStreamPlayer2D

# Tentukan volume normal yang kamu inginkan (dalam Decibel)
# 0.0 adalah volume asli file, -10.0 lebih pelan. Sesuaikan selera.
var target_volume = -5.0

signal level_finished

func _ready():
	start_bgm_fade_in()
	# Loop all the shards
	for shard in shards_container.get_children():
		# Make sure the child has a signal
		if shard.has_signal("shard_collected"):
			shard.shard_collected.connect(_on_shard_collected)
	
	# Baris ini sekarang akan berhasil karena fungsinya sudah ada di bawah
	portal.player_entered_portal.connect(_on_portal_entered)
	
	print("Game dimulai! Kumpulkan " + str(total_shards_needed) + " shard.")

# Methods for processing retrieved shards
func _on_shard_collected():
	current_shards += 1
	print("Shard terkumpul: ", current_shards)
	
	# --- LOGIKA BARU ---
	# Panggil fungsi di player untuk memunculkan angka
	if player and player.has_method("show_shard_number"):
		player.show_shard_number(current_shards)
	# -------------------

	if current_shards >= total_shards_needed:
		open_the_portal()

func open_the_portal():
	print("Semua shard terkumpul! Portal terbuka!")
	portal.unlock_portal()

# --- FUNGSI YANG HILANG TADI ---
func _on_portal_entered():
	print("Level Selesai! Player masuk portal.")
	# Kirim sinyal ke Main agar game dipause/muncul menu menang
	level_finished.emit()

func start_bgm_fade_in():
	# 1. Set volume awal ke "Mute" (sangat kecil, misal -80 dB)
	bgm.volume_db = -20.0
	
	# 2. Mainkan lagu
	bgm.play()
	
	# 3. Buat Tween untuk menaikkan volume perlahan
	var tween = create_tween()
	# Naikkan 'volume_db' dari -80 ke target_volume selama 3 detik
	tween.tween_property(bgm, "volume_db", target_volume, 3.0)

# Panggil fungsi ini nanti ketika level selesai atau pindah scene
func stop_bgm_fade_out():
	var tween = create_tween()
	# Turunkan 'volume_db' ke -80 selama 2 detik
	tween.tween_property(bgm, "volume_db", -80.0, 0.5)
	
	# Opsional: Matikan player sepenuhnya setelah fade out selesai
	tween.tween_callback(bgm.stop)
