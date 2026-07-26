extends Node

var hitbox_offset: int
const move_window := 0.3
enum Move {PARRY, SLASH, DODGE}
var viewport_size

func _ready() -> void:
	viewport_size = get_viewport().get_visible_rect().size
	hitbox_offset = int(viewport_size.y * 0.2)
