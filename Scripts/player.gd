extends CharacterBody3D


@onready var game = %Game

const top_left = Vector3(-1, 1, 0)
const bot_right = Vector3(1, 0, 0)
var moving = false

var movement_tween

signal player_died

func _create_tween() -> void:
	movement_tween = get_tree().create_tween()
	movement_tween.finished.connect(_finished_moving)
	movement_tween.set_ease(Tween.EASE_OUT_IN)
	moving = true

func _finished_moving() -> void:
	moving = false
	movement_tween.kill()

func receive_hit() -> void:
	print("Got it")
	pass
	
	
func receive_collectible() -> void:
	game.increase_score(1)
	pass

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, -input_dir.y, 0)).normalized()
	if direction:
		if not moving:
			if direction.x > 0:
				if position.x < bot_right.x :
					_create_tween()
					movement_tween.tween_property(self, "position:x", position.x + 1, 0.1)
			elif direction.x < 0: 
				if position.x > top_left.x :
					_create_tween()
					movement_tween.tween_property(self, "position:x", position.x - 1, 0.1)
			elif direction.y < 0:
				if position.y > bot_right.y : 
					_create_tween()
					movement_tween.tween_property(self, "position:y", position.y - 1, 0.1)
			elif direction.y > 0:
				if position.y < top_left.y :
					_create_tween()
					movement_tween.tween_property(self, "position:y", position.y + 1, 0.1)

	# Clamp the player's position to the screen.
	position.x = clamp(position.x, top_left.x, bot_right.x)
	position.y = clamp(position.y, bot_right.y, top_left.y)
