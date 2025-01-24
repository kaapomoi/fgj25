extends CSGSphere3D

var rotation_speed :float = 1.6


#list of obstacles
"res://Scenes/sphere_obstacle.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_spin_globe(delta)
	pass



func _spin_globe(delta: float) -> void:
	rotate_x(rotation_speed * delta)


func spawn_obstacle() -> void:
	
	pass
