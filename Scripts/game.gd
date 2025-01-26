extends Node3D

# uncapped
var difficulty :float = 1
var difficulty_scaler_factor:float = 0.05

var _score :int = 0
var highscore :int = 0
var player

enum GAME_STATE {PLAYING = 0, PAUSED = 1, START = 2, END = 3}

var game_state: GAME_STATE = GAME_STATE.START

@onready var game_end_stream = $GameEndStreamPlayer
@onready var main_audio = $AudioStreamPlayer
@onready var score_text = $Score
@onready var highscore_text = $Highscore
@onready var game_end_timer = $GameEndTimer

@onready var scene_tree: SceneTree = get_tree()

const save_file_path = "user://save.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_game()

	player = preload("res://Scenes/player.tscn").instantiate()
	add_child(player)
	player.player_died.connect(_on_player_player_died)
	player.player_ready.connect(show_tutorial)
	player.get_tree().set_pause(false)


func receive_collectable() -> void:
	increase_score(1)

func _initialize_game() -> void:
	game_state = GAME_STATE.START
	scene_tree.set_pause(true)
	load_save_file()
	highscore_text.text = "Highscore: " + str(highscore)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale_difficulty_timer(delta)
	pass


func scale_difficulty_timer(delta: float) -> void:
	if game_state == GAME_STATE.PLAYING:
		difficulty += delta * difficulty_scaler_factor
	pass
	
func _input(event: InputEvent) -> void:
	if game_state == GAME_STATE.START && (event.is_action_pressed("ui_accept") 
										|| event.is_action_pressed("ui_up")
										|| event.is_action_pressed("ui_down")
										|| event.is_action_pressed("ui_left")
										|| event.is_action_pressed("ui_right")):
		start_game()
			
			
	if event.is_action_pressed("ui_cancel") && game_state != GAME_STATE.START:	
		if scene_tree:
			scene_tree.set_pause(!scene_tree.paused)
			game_state = scene_tree.paused as int as GAME_STATE
	
	
func start_game() -> void:
	if scene_tree:
		scene_tree.set_pause(false)
		game_state = GAME_STATE.PLAYING
		var slow_scale = get_tree().create_tween()
		slow_scale.set_ease(Tween.EASE_IN)
		slow_scale.set_trans(Tween.TRANS_SINE)
		slow_scale.tween_property($Globe, "base_rotation_speed", PI/4, 6.0)
		update_score_text()
		$TutorialLabel.hide()

		if not main_audio.playing:
			main_audio.play()
			
func load_save_file() -> void:
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	if save_file:
		var save_data = JSON.parse_string(save_file.get_line())
		if save_data:
			if save_data["highscore"]:
				print("Save file Highscore: " + str(save_data["highscore"]))
				highscore = save_data["highscore"]
				
	#json.parse_string()
	
func save_save_file() -> void:
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	var save_data = {"highscore": highscore}
	print("Saving data " + str(save_data))
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	
	
func restart_game() -> void:
	difficulty = 1
	_score = 0
	game_state = GAME_STATE.START

	$Globe.despawn_obstacles_and_collectables()

	player = preload("res://Scenes/player.tscn").instantiate()
	add_child(player)
	player.player_died.connect(_on_player_player_died)
	player.player_ready.connect(show_tutorial)

func show_tutorial() -> void:
	$TutorialLabel.show()
	
func increase_score(points: int) -> void:
	_score += points
	update_score_text()

func update_score_text() -> void:
	score_text.text = "Score: " + str(_score)

func _on_player_player_died() -> void:
	if _score > highscore:
		highscore = _score
		save_save_file()

	game_state = GAME_STATE.END

	#play sound
	main_audio.stop()
	game_end_stream.play()
	game_end_timer.start()

	# Slow down the globe
	var slow_scale = get_tree().create_tween()
	slow_scale.set_ease(Tween.EASE_OUT)
	slow_scale.set_trans(Tween.TRANS_CIRC)
	slow_scale.tween_property($Globe, "base_rotation_speed", 0.0, 6.0)

	$ObstacleDespawnTimer.start()

func _on_game_end_timer_timeout() -> void:
	player.queue_free()

	restart_game()
