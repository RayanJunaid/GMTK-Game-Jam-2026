extends Node

@export var enemy_scene: PackedScene
var hp := 10
var score := 0
@onready var health_bar = $CanvasLayer/HealthBar
const initial_time := 5.0
var enemies: Dictionary[Vector2i, Enemy] = {}
var last_spawned_enemies: Dictionary[Vector2i, Enemy] = {}
var direction: Vector2i
var can_move = false
var facing_up := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.wait_time = initial_time
	$CanvasLayer/ScoreLabel.text = "Score: 0"
	health_bar.max_value = hp
	health_bar.value = hp
	for sign in [-1, 1]:
		for axis in [0, 1]:
			var dir = Vector2i(0, 0)
			dir[axis] = sign
			enemies[dir] = null
			last_spawned_enemies[dir] = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$SpawnTimer.wait_time = initial_time / (-0.00002 * Time.get_ticks_msec() + 1)
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
	$PlayerSprite.position = direction * (Globals.hitbox_offset - 50)
	
	# idle animation handling
	if direction == Vector2i(0, -1) and $PlayerSprite.animation.begins_with("idle"):
		facing_up = true
		$PlayerSprite.play("idle_up")
	elif direction != Vector2i(0, 0) and facing_up and $PlayerSprite.animation.begins_with("idle"):
		facing_up = false
		$PlayerSprite.play("idle_down")
	
	if direction == Vector2i(0, 0):
		return
	# During timing window, if player executes correct action in the right position then dequeue
	var enemy = enemies[direction]
	if enemy == null:
		return
	
	if can_move and Input.is_action_just_pressed(Globals.Move.keys()[enemy.move]):
		can_move = false
		play_player_animation(enemy.move)
		$Label.text = Globals.Move.keys()[enemy.move]
		enemy.die()
		score += 1
		$CanvasLayer/ScoreLabel.text = "Score: " + str(score)


func _on_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var enemy_direction = Vector2i(0, 0)
	var enemy_move = randi_range(0, 2)
	enemy_direction[randi_range(0, 1)] = randi_range(0, 1) * 2 - 1
	var enemy_countdown = 5.0
	var last_enemy = last_spawned_enemies[enemy_direction]
	if last_enemy != null:
		enemy_countdown = last_enemy.get_node("DespawnTimer").time_left
	
	enemy.construct(enemy_direction, enemy_move, enemy_countdown) # stop it randomly going too fast by altering lb
	enemy.attacked.connect(_on_enemy_attacked)
	add_child(enemy)
	enemy.play_enemy_animation("run")
	last_spawned_enemies[enemy_direction] = enemy


func _on_enemy_attacked(enemy: Enemy) -> void:
	enemies[enemy.direction] = enemy
	can_move = true
	enemy.play_enemy_animation("attack")
	await enemy.despawn
	if can_move: 
		$Label.text = "Too early/late"
		can_move = false
		damage(1)
	
	enemies[enemy.direction] = null


func damage(amount: int):
	hp -= amount
	hp = max(hp, 0)
	create_tween().tween_property(
		health_bar,
		"value",
		hp,
		0.15
		)

	if hp == 0:
		game_over()


func game_over():
	get_tree().paused = true
	$CanvasLayer/GameOverScreen/FinalScoreLabel.text = "Final Score: " + str(score)
	$CanvasLayer/GameOverScreen.visible = true

func play_player_animation(move: Globals.Move):
	var move_str := ""
	var dir_str := ""
	var anim := ""
	
	match move:
		Globals.Move.SLASH:
			move_str = "slash"
		Globals.Move.PARRY:
			move_str = "parry"
		Globals.Move.THRUST:
			move_str = "thrust"

	match direction:
		Vector2i(-1, 0):
			dir_str = "left"
		Vector2i(1, 0):
			dir_str = "right"
		Vector2i(0, -1):
			dir_str = "up"
		Vector2i(0, 1):
			dir_str = "down"
		_:
			return
	anim = move_str + "_" + dir_str
	$PlayerSprite.play(anim)
	$PlayerSprite.set_frame_and_progress(0, 0.0)


func _on_player_sprite_animation_finished() -> void:
	if facing_up:
		$PlayerSprite.play("idle_up")
	else:
		$PlayerSprite.play("idle_down")


func _on_retry_button_pressed() -> void:
	print("Retry pressed")
	get_tree().paused = false
	get_tree().reload_current_scene()
