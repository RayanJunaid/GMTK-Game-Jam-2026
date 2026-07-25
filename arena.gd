extends Node

@export var enemy_scene: PackedScene
var hp := 10
var enemies: Dictionary[Vector2i, Enemy] = {}
var direction: Vector2i
var can_move = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera.zoom = get_viewport().get_visible_rect().size / 2
	$SpawnTimer.wait_time = 5.0
	for sign in [-1, 1]:
		for axis in [0, 1]:
			var dir = Vector2i(0, 0)
			dir[axis] = sign
			enemies[dir] = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
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
	$PlayerSprite.position = direction * (Globals.hitbox_offset - 0.05)
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
	enemy.construct(enemy_direction, enemy_move, randf_range(5, 5)) # need to fix the countdown calc
	enemy.attacked.connect(_on_enemy_attacked)
	add_child(enemy)


func _on_enemy_attacked(enemy: Enemy) -> void:
	enemies[enemy.direction] = enemy
	can_move = true
	await enemy.despawn
	if can_move: 
		$Label.text = "Too early/late"
		can_move = false
		enemy.queue_free()
	enemies[enemy.direction] = null
