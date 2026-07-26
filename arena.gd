extends Node

@export var enemy_scene: PackedScene
var hp := 10
const initial_time := 5.0 
var enemies: Dictionary[Vector2i, Enemy] = {}
var last_spawned_enemies: Dictionary[Vector2i, Enemy] = {}
var direction: Vector2i
var can_move = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.wait_time = initial_time
	for sign in [-1, 1]:
		for axis in [0, 1]:
			var dir = Vector2i(0, 0)
			dir[axis] = sign
			enemies[dir] = null
			last_spawned_enemies[dir] = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$SpawnTimer.wait_time = initial_time * exp(-0.0001 * Time.get_ticks_msec()) # use diff function
	$HitboxSprite.visible = true
	# Move player to a marker based on input, and set player direction
	if Input.is_action_pressed("left"):
		direction = Vector2i(-1, 0)
	elif Input.is_action_pressed("right"):
		direction = Vector2i(1, 0)
	elif Input.is_action_pressed("up"):
		direction = Vector2i(0, -1)
	elif Input.is_action_pressed("down"):
		direction = Vector2i(0, 1)
	else:
		direction = Vector2i(0, 0)
		$HitboxSprite.visible = false
	$HitboxSprite.position = direction * Globals.hitbox_offset
	$PlayerSprite.position = direction * (Globals.hitbox_offset - 100)
	if direction == Vector2i(0, 0):
		return
	
	
	# During timing window, if player executes correct action in the right position then dequeue
	var enemy = enemies[direction]
	if enemy == null:
		return
		
	if can_move and Input.is_action_just_pressed(Globals.Move.keys()[enemy.move]):
		can_move = false
		$Label.text = Globals.Move.keys()[enemy.move]
		enemy.queue_free()


func _on_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var enemy_direction = Vector2i(0, 0)
	var enemy_move = randi_range(0, 2)
	enemy_direction[randi_range(0, 1)] = randi_range(0, 1) * 2 - 1
	var enemy_countdown = 2.0
	var last_enemy = last_spawned_enemies[enemy_direction]
	if last_enemy != null:
		enemy_countdown = last_enemy.get_node("DespawnTimer").time_left
	
	enemy.construct(enemy_direction, enemy_move, randf_range(enemy_countdown, enemy_countdown + 1)) # stop it randomly going too fast by altering lb
	enemy.attacked.connect(_on_enemy_attacked)
	add_child(enemy)
	last_spawned_enemies[enemy_direction] = enemy


func _on_enemy_attacked(enemy: Enemy) -> void:
	enemies[enemy.direction] = enemy
	can_move = true
	await enemy.despawn
	if can_move: 
		$Label.text = "Too early/late"
		can_move = false
	
	enemies[enemy.direction] = null
