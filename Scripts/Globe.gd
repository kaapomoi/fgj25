extends CSGSphere3D


@onready var game = %Game
#default spawn location for bot-mid
@onready var base_spawn_location: Node3D = $"../SpawnLocation"
@onready var base_spawn_location2: Node3D = $"../SpawnLocation2"
@onready var base_spawn_location3: Node3D = $"../SpawnLocation3"
@onready var base_spawn_location4: Node3D = $"../SpawnLocation4"
@onready var obstacles_parent :Node3D = $Obstacles

var base_rotation_speed :float = 0.0
var rotation_difficulty_multiplier :float = 0.3
var rotation_speed :float = 0.0
var max_rotation_speed :float = PI/2


#debug
var total_rotation = 0.0

#radians
var base_obstacle_spawn_interval :float = PI/2
var base_collectable_spawn_interval :float = PI/2/3
var delta_rotation :float = 0.0

#how many open spots in the grid we leave when spawning set of obstacles (5-1)
var open_spots :int = 1

#							top-left, 			top-mid, 		top-right, 			bot-left, 			bot-mid, 			bot-right
var spawn_offset :Array = [Vector2(-1.0, -1.0), Vector2(0.0, -1.0), Vector2(1.0, -1.0) ,Vector2(-1.0, 0.0), Vector2(0.0, 0.0), Vector2(1.0, 0.0)]
var spawn_radius_offset :float = 0.5
var spawn_radiant_offset :float = PI/2

#list of obstacles
var flying_obstacles :Array = []
var ground_obstacles :Array = []
const flying_obstacles_path = "res://Scenes/Obstacles/Flying/"
const grounded_obstacles_path = "res://Scenes/Obstacles/Ground/"

#collectables
@onready var collectable = preload("res://Scenes/collectable.tscn")
@onready var obstacle_timer :Timer = $ObstacleTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_collectable_spawn_interval = base_obstacle_spawn_interval / 3
	_load_obstacle_resources()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("Current speed " + str(base_rotation_speed * delta * game.difficulty * rotation_difficulty_multiplier))
	#print("Current Open slots = " + str(open_spots))
	#print("SpawnLocation: " + str(base_spawn_location.rotation))
	_spin_globe(delta)
	_handle_delta_rotation_and_spawning(delta)
	

func _load_obstacle_resources() -> void:
	#Flying obstacles
	var dir = DirAccess.open(flying_obstacles_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				print("Found file: " + file_name)
				if file_name.ends_with("tscn"):
					var obstacle = load(dir.get_current_dir() + "/" + file_name)
					if obstacle:
						flying_obstacles.append(obstacle)
					else:
						print("Error loading obstacle: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
	#Ground obstacles
	dir = DirAccess.open(grounded_obstacles_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				print("Found file: " + file_name)
				if file_name.ends_with("tscn"):
					var obstacle = load(dir.get_current_dir() + "/" + file_name)
					if obstacle:
						ground_obstacles.append(obstacle)
					else:
						print("Error loading obstacle: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func _calculate_current_open_spots() -> void:
	open_spots = clampi(floori(7.0 - game.difficulty), 1, 5)
	pass

func _spin_globe(delta: float) -> void:
	rotation_speed = clampf(base_rotation_speed * delta * game.difficulty * rotation_difficulty_multiplier, 0, max_rotation_speed)
	rotate_x(rotation_speed)
	

func _spawn_set_of_obstacles_and_collectable() -> void:
	print("Spawned new obstacles")
	#calculate number of open slots
	_calculate_current_open_spots()
	#get (grid) positions which where we want to spawn obstacles
	var positions = [0, 1, 2, 3, 4, 5]
	positions.shuffle()
	var random_index = randi_range(0, 5)
	spawn_collectables_between_obstacles(random_index)
	if open_spots > positions.size():
		print("Error, too many open positions")
		pass
	positions.resize(6 - open_spots)
	print(positions)
	for n in range(positions.size()):
		spawn_obstacle(positions[n])
		
		
func spawn_collectable(position_index : int) -> void:
	var instance = collectable.instantiate() as Node3D
	if instance:
		obstacles_parent.add_child(instance)
		var spawn_position :Vector3 = _get_relative_spawn_location(position_index)
		instance.global_position = spawn_position
		instance.rotate_x(-PI/2 - rotation.x)
		
func spawn_collectables_between_obstacles(position_index: int) -> void:
	var instance1 = collectable.instantiate() as Node3D
	obstacles_parent.add_child(instance1)
	instance1.global_position = _get_collectable_spawn_location(position_index, 1)
	var instance2 = collectable.instantiate() as Node3D
	obstacles_parent.add_child(instance2)
	instance2.global_position = _get_collectable_spawn_location(position_index, 2)
	var instance3 = collectable.instantiate() as Node3D
	obstacles_parent.add_child(instance3)
	instance3.global_position = _get_collectable_spawn_location(position_index, 3)
	
func _handle_delta_rotation_and_spawning(_delta: float) -> void:
	delta_rotation += rotation_speed
	if delta_rotation > base_obstacle_spawn_interval:
		_spawn_set_of_obstacles_and_collectable()
		delta_rotation = 0.0

func spawn_obstacle(position_index : int) -> void:
	#spawn flying obstacle
	if position_index < 3:
		if !flying_obstacles.is_empty():
			print("Trying to instantiate flying resource, can it init?? " + str(flying_obstacles[0].can_instantiate()))
			var random_obstacle = randi_range(0, flying_obstacles.size() - 1)
			var instance = flying_obstacles[random_obstacle].instantiate() as Node3D
			obstacles_parent.add_child(instance)
			#set position and rotation
			var spawn_position :Vector3 = _get_relative_spawn_location(position_index)
			instance.global_position = spawn_position
			instance.rotate_x(-PI/2 - rotation.x)
			#instance.global_rotate(Vector3(1, 0, 0), -PI/4)
	else:
		if !ground_obstacles.is_empty():
			print("Trying to instantiate grounded resource, can it init?? " + str(ground_obstacles[0].can_instantiate()))
			var random_obstacle = randi_range(0, ground_obstacles.size() - 1)
			var instance = ground_obstacles[random_obstacle].instantiate() as Node3D
			obstacles_parent.add_child(instance)
			var spawn_position :Vector3 = _get_relative_spawn_location(position_index)
			instance.global_position = spawn_position
			#instance.global_rotate(Vector3(1, 0, 0), -PI/4)
			instance.rotate_x(-PI/2 - rotation.x)
	pass
	
func despawn_obstacles_and_collectables() -> void:
	for c in obstacles_parent.get_children():
		c.queue_free()

func _on_obstacle_despawn_timer_timeout() -> void:
	for c in obstacles_parent.get_children():
		var scale_tween = get_tree().create_tween()
		scale_tween.set_ease(Tween.EASE_OUT)
		scale_tween.set_trans(Tween.TRANS_SINE)
		scale_tween.tween_property(c, "scale", Vector3(0.001, 0.001, 0.001), 0.5)

func _get_relative_spawn_location(position_index: int) -> Vector3:
	var spawn_location = Vector3(0.0, - radius,  - radius - spawn_radius_offset) + Vector3(spawn_offset[position_index].x, 0.0, spawn_offset[position_index].y)
	#spawn_location = base_spawn_location.position + Vector3(spawn_offset[position_index].x, 0.0, spawn_offset[position_index].y)
	return spawn_location
	
func _get_collectable_spawn_location(position_index: int, i: int) -> Vector3:
	if i == 1:
		return base_spawn_location2.position + Vector3(spawn_offset[position_index].x, 0.0, spawn_offset[position_index].y)
	if i == 2:
		return base_spawn_location3.position + Vector3(spawn_offset[position_index].x, 0.0, spawn_offset[position_index].y)
	if i == 3:
		return base_spawn_location4.position + Vector3(spawn_offset[position_index].x, 0.0, spawn_offset[position_index].y)
	
	return Vector3.ZERO


