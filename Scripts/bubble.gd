extends CSGSphere3D


var points :int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func receive_hit() -> void:
	print("Got it")
	pass


#func _on_area_3d_area_entered(area: Area3D) -> void:
	#print("Got hit")
	#pass # Replace with function body.
