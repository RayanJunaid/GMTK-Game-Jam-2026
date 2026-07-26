class_name Enemy
extends Node2D

var direction: Vector2i
var move: Globals.Move
var damage: int
var _origin
signal attacked(enemy: Enemy)
signal despawn()


func construct(direction: Vector2i, move: Globals.Move, countdown: float):
	self.direction = direction
	self.move = move
	$DespawnTimer.wait_time = countdown
	$AttackTimer.wait_time = countdown - Globals.move_window
	$EnemyAttackLabel.text = Globals.Move.keys()[move]

func _ready() -> void:
	# Move enemy from it's initial position to the corresponding marker
	_origin = Vector2(direction) * Globals.viewport_size / 2
	global_position = _origin

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target = Vector2(direction) * Globals.hitbox_offset
	global_position = _origin.lerp(target, time_to_progress($DespawnTimer.wait_time - $DespawnTimer.time_left))
	$EnemyTimerLabel.text = str(int(ceil($DespawnTimer.time_left))) + "s"


# derivation: https://www.desmos.com/calculator/4eh6ds3jhq
func time_to_progress(time: float) -> float:
	var reach_time = $DespawnTimer.wait_time - Globals.move_window / 2
	if time < reach_time:
		return time/reach_time
	else: 
		return 1

func _on_attack_timer_timeout() -> void:
	attacked.emit(self)


func _on_travel_timer_timeout() -> void:
	despawn.emit()
