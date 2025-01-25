extends Node


@onready var player = $"/root/Root/Game/Player"
@onready var game = $"/root/Root/Game"
@onready var audioplayer = $PickupSoundPlayer
@onready var timer = $Timer
@onready var sphere = $GraphicSphere

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node3D) -> void:
	if player && game.game_state != game.GAME_STATE.END:
		audioplayer.play()	
		timer.start()
		player.receive_collectible()
		sphere.queue_free()
		

func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
