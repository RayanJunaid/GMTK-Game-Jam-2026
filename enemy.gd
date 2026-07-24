extends Node2D

var attack_target: Marker2D
var target_distance
enum attack_types {PARRY, SLASH, DODGE}
var attack_type
var damage: int
var spawnpoint_vector: Vector2
var countdown: float
signal attacked(attack_type, attack_target)


func construct(attack_target: Marker2D, spawnpoint_vector: Vector2, countdown: float):
	self.attack_target = attack_target
	self.spawnpoint_vector = spawnpoint_vector
	self.countdown = countdown


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = spawnpoint_vector
	target_distance = spawnpoint_vector.distance_to(attack_target.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Move enemy from it's initial position to the corresponding marker
	global_position = global_position.move_toward(attack_target.global_position, delta*target_distance/countdown)
	
	$EnemyTimerLabel.text = str(int(ceil($EnemyTimer.time_left))) + "s"


#On coundown timeout emit a signal to be caught by the parent
func _on_enemy_timer_timeout() -> void:
	attacked.emit(attack_type, attack_target)
	queue_free()
