extends Node2D

enum directions {CENTRE, UP, DOWN, LEFT, RIGHT}
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Offset the player's sprite so it isn't on top of the hitbox
	$HitboxSprite.visible = true
	if direction == directions.UP:
		$PlayerSprite.position = Vector2(0, 50)
	elif direction == directions.DOWN:
		$PlayerSprite.position = Vector2(0, -50)
	elif direction == directions.LEFT:
		$PlayerSprite.position = Vector2(50, 0)
	elif direction == directions.RIGHT:
		$PlayerSprite.position = Vector2(-50, 0)
	else:
		$PlayerSprite.position = Vector2(0, 0)
		$HitboxSprite.visible = false


func _on_arena_parried() -> void:
	print("parried!")


func _on_arena_took_damage(damage: Variant) -> void:
	print("took damage: ", damage)
