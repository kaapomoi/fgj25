extends Node


@onready var game = $"/root/Root/Game"
@onready var audioplayer = $PickupSoundPlayer
@onready var timer = $Timer
@onready var sphere = $GraphicSphere
@onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node3D) -> void:
	if game.game_state != game.GAME_STATE.END:
		audioplayer.play()	
		timer.start()
		particles.emitting = true
		game.receive_collectable()
		sphere.hide()
		

func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
