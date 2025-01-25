extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_animation("Armature|ArmatureAction").loop_mode = Animation.LOOP_LINEAR
	set_current_animation("Armature|ArmatureAction")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
