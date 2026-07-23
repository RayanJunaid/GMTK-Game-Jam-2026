extends Node2D

@export var enemy_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$SpawnTimer.wait_time = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("left"):
		$Player.global_position = $Positions/LeftMarker.global_position
	elif Input.is_action_pressed("right"):
		$Player.global_position = $Positions/RightMarker.global_position
	elif Input.is_action_pressed("up"):
		$Player.global_position = $Positions/UpMarker.global_position
	elif Input.is_action_pressed("down"):
		$Player.global_position = $Positions/DownMarker.global_position
	else:
		$Player.global_position = $Positions/CentreMarker.global_position
	
	


func _on_spawn_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.spawnpoint_vector = Vector2(0 ,540) #TEST
	enemy.countdown = 5
	enemy.attack_target = $Positions/LeftMarker #TEST
	$Enemies.add_child(enemy)
