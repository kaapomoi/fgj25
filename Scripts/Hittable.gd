extends Area3D

@onready var game = $"/root/Root/Game"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("New instance of hittable")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("receive_hit") && game.game_state != game.GAME_STATE.END:
		body.receive_hit()
		
