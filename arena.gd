extends Node

@export var enemy_scene: PackedScene
var direction: Vector2i
var expected_direction: Vector2i
var parry_window := 0.25
var can_parry := false
signal took_damage(damage)
signal parried

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.wait_time = 5.0


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
	$HitboxSprite.position = direction * Globals.offset
	$PlayerSprite.position = direction * (Globals.offset - 100)
	
	
	# During parry window, if player parries in the right position then emit parry signal
	if can_parry and Input.is_action_just_pressed("parry"):
		if direction == expected_direction:
			parried.emit()
			can_parry = false
			print("parried")


func _on_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var enemy_direction = Vector2i(0, 0)
	enemy_direction[randi_range(0, 1)] = randi_range(0, 1) * 2 - 1
	enemy.construct(enemy_direction, randf_range(2, 5))
	enemy.attacked.connect(_on_enemy_attacked)
	add_child(enemy)


func _on_enemy_attacked(attack_type, enemy_direction) -> void:
	can_parry = true
	expected_direction = enemy_direction
	await get_tree().create_timer(parry_window).timeout
	if can_parry:
		print("Too early/late")
		took_damage.emit(1)
	can_parry = false
