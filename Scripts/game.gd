extends Node3D

# uncapped
var difficulty :float = 1
var difficulty_scaler_factor:float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale_difficulty_timer(delta)
	pass


func scale_difficulty_timer(delta: float) -> void:
	difficulty += delta * difficulty_scaler_factor
	pass
