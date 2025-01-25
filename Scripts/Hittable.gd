extends Area3D

@onready var game = $"/root/Root/Game"
@onready var player = $"/root/Root/Game/Player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("New instance of hittable")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node3D) -> void:
	player.receive_hit()
	pass # Replace with function body.
