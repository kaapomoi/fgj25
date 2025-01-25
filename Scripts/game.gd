extends Node3D

# uncapped
var difficulty :float = 1
var difficulty_scaler_factor:float = 0.05

var _score :int = 0
var highscore :int = 0

enum GAME_STATE {PLAYING = 0, PAUSED = 1, START = 2}

var game_state: GAME_STATE = GAME_STATE.START


@onready var score_text = $Score
@onready var highscore_text = $Highscore

@onready var scene_tree: SceneTree = get_tree()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_game()
	pass # Replace with function body.


func _initialize_game() -> void:
	game_state = GAME_STATE.START
	scene_tree.set_pause(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale_difficulty_timer(delta)
	pass


func scale_difficulty_timer(delta: float) -> void:
	difficulty += delta * difficulty_scaler_factor
	pass
	
func _input(event: InputEvent) -> void:
	if game_state == GAME_STATE.START && event.is_action_pressed("ui_accept"):
		start_game()
			
			
	if event.is_action_pressed("ui_cancel") && game_state != GAME_STATE.START:	
		if scene_tree:
			scene_tree.set_pause(!scene_tree.paused)
			game_state = scene_tree.paused as int as GAME_STATE
	
	
func start_game() -> void:
	if scene_tree:
			scene_tree.set_pause(false)
			game_state = GAME_STATE.PLAYING
			
	
func increase_score(points: int) -> void:
	_score += points
	score_text.text = "Score: " + str(_score)


func _on_player_player_died() -> void:
	highscore = _score
	highscore_text = "Highscore: " + str(highscore)
	#reset game
	pass # Replace with function body.
