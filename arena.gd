extends Node2D

@export var enemy_scene: PackedScene
var parry_window := 0.25
var can_parry := false
var expected_target: Marker2D
signal took_damage(damage)
signal parried

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.wait_time = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Move player to a marker based on input, and set player direction
	if Input.is_action_pressed("left"):
		$Player.global_position = $Positions/LeftMarker.global_position
		$Player.direction = $Player.directions.LEFT
	elif Input.is_action_pressed("right"):
		$Player.global_position = $Positions/RightMarker.global_position
		$Player.direction = $Player.directions.RIGHT
	elif Input.is_action_pressed("up"):
		$Player.global_position = $Positions/UpMarker.global_position
		$Player.direction = $Player.directions.UP
	elif Input.is_action_pressed("down"):
		$Player.global_position = $Positions/DownMarker.global_position
		$Player.direction = $Player.directions.DOWN
	else:
		$Player.global_position = $Positions/CentreMarker.global_position
		$Player.direction = $Player.directions.CENTRE
	
	# During parry window, if player parries in the right position then emit parry signal
	if can_parry and Input.is_action_just_pressed("parry"):
		if $Player.global_position == expected_target.global_position:
			parried.emit()
			can_parry = false
			expected_target = null


func _on_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.construct($Positions/LeftMarker, Vector2(0 ,540), 5.0)
	enemy.attacked.connect(_on_enemy_attacked)
	$Enemies.add_child(enemy)

func _on_enemy_attacked(attack_type, attack_target) -> void:
	can_parry = true
	expected_target = attack_target
	await get_tree().create_timer(parry_window).timeout
	if can_parry:
		print("Too early/late")
		took_damage.emit(1)
	can_parry = false
