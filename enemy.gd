extends Node2D

var target_distance
var direction
enum attack_types {PARRY, SLASH, DODGE}
var attack_type
var damage: int
signal attacked(attack_type, direction)


func construct(direction: Vector2i, countdown: float):
	self.direction = direction
	$EnemyTimer.wait_time = countdown


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Move enemy from it's initial position to the corresponding marker
	var viewport_size = get_viewport().get_visible_rect().size
	var origin = Vector2(direction) * viewport_size / 2
	var target = Vector2(direction) * Globals.offset
	global_position = origin.lerp(target, ($EnemyTimer.wait_time - $EnemyTimer.time_left)/$EnemyTimer.wait_time)
	$EnemyTimerLabel.text = str(int(ceil($EnemyTimer.time_left))) + "s"

#On coundown timeout emit a signal to be caught by the parent
func _on_enemy_timer_timeout() -> void:
	attacked.emit(attack_type, direction)
	queue_free()
