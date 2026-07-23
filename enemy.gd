extends Node2D

var attack_target: Marker2D
var target_distance
enum attack_types {PARRY, SLASH, DODGE}
var attack_type
var spawnpoint_vector: Vector2
var countdown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = spawnpoint_vector
	target_distance = spawnpoint_vector.distance_to(attack_target.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position.move_toward(attack_target.global_position, delta*target_distance/countdown)
	
	$EnemyTimerLabel.text = str(int(ceil($EnemyTimer.time_left))) + "s"


func _on_timer_timeout() -> void:
	$EnemyTimerLabel.text = "timeout"
	queue_free()
