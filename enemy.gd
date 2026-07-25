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
	$TravelTimer.wait_time = countdown
	$AttackTimer.wait_time = countdown - Globals.move_window
	$EnemyAttackLabel.text = Globals.Move.keys()[move]

func _ready() -> void:
	#Move enemy from it's initial position to the corresponding marker
	global_position = Vector2(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var target = Vector2(direction) * Globals.hitbox_offset
	global_position = Vector2(direction).lerp(target, ($TravelTimer.wait_time - $TravelTimer.time_left)/$TravelTimer.wait_time)
	$EnemyTimerLabel.text = str(int(ceil($TravelTimer.time_left))) + "s"


func _on_attack_timer_timeout() -> void:
	attacked.emit(self)


func _on_travel_timer_timeout() -> void:
	await get_tree().create_timer(Globals.move_window).timeout
	despawn.emit()
