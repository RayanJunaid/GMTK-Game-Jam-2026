class_name Enemy
extends Node2D

var direction: Vector2i
var move: Globals.Move
var damage: int
var dead := false
var _origin
signal attacked(enemy: Enemy)
signal despawn()

const ORC_FRAMES = [
	preload("res://Assets/Orc1Frames.tres"),
	preload("res://Assets/Orc2Frames.tres"),
	preload("res://Assets/Orc3Frames.tres"),
]

const PLANT_FRAMES = [
	preload("res://Assets/Plant1Frames.tres"),
	preload("res://Assets/Plant2Frames.tres"),
	preload("res://Assets/Plant3Frames.tres"),
]

const SLIME_FRAMES = [
	preload("res://Assets/Slime1Frames.tres"),
	preload("res://Assets/Slime2Frames.tres"),
	preload("res://Assets/Slime3Frames.tres"),
]

func construct(direction: Vector2i, move: Globals.Move, countdown: float):
	self.direction = direction
	self.move = move
	
	match move:
		Globals.Move.PARRY:
			$EnemySprite.sprite_frames = ORC_FRAMES.pick_random()
		Globals.Move.SLASH:
			$EnemySprite.sprite_frames = PLANT_FRAMES.pick_random()
		Globals.Move.THRUST:
			$EnemySprite.sprite_frames = SLIME_FRAMES.pick_random()
	
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


func die():
	if dead:
		return

	dead = true

	$DespawnTimer.stop()
	$AttackTimer.stop()

	play_enemy_animation("die")

	await $EnemySprite.animation_finished
	queue_free()


func _on_attack_timer_timeout() -> void:
	attacked.emit(self)


func _on_travel_timer_timeout() -> void:
	despawn.emit()
	await die()

func play_enemy_animation(action: String):
	var anim = action + "_" + direction_string()
	$EnemySprite.play(anim)
	$EnemySprite.set_frame_and_progress(0, 0.0)
	
	if action == "attack" or action == "die":
		$EnemySprite.speed_scale = 1/Globals.move_window

func direction_string() -> String:
	match direction:
		Vector2i(-1, 0):
			return "left"
		Vector2i(1, 0):
			return "right"
		Vector2i(0, -1):
			return "up"
		Vector2i(0, 1):
			return "down"
	return "down"
