extends Area2D

# ============================================================================
# Ken Bus Adventure — Power-up
# ============================================================================
# Types: rocket, shield, turbo, fireworks, doubledeck
# Floats with sine wave, collected on bus contact
# ============================================================================

signal collected(type: String)
signal activated(type: String)

@export var powerup_type: String = "rocket"

var _level_name: String = "citta"
var _main: Node2D = null
var _sprite: Sprite2D = null
var _glow: Sprite2D = null
var _bob_offset: float = 0.0
var _base_y: float = 0.0
var _bob_amplitude: float = 10.0
var _bob_frequency: float = 2.5
var _rotate_speed: float = 1.5

func _ready() -> void:
	_main = get_parent()
	area_entered.connect(_on_area_entered)

	_sprite = $Sprite2D if has_node("Sprite2D") else null
	_glow = $Glow if has_node("Glow") else null

	# Collision layer: PowerUps (layer 4)
	collision_layer = (1 << 3)
	collision_mask = 0

	rotation = randf() * TAU


func _process(delta: float) -> void:
	# Float bob
	_bob_offset += delta * _bob_frequency
	position.y = _base_y + sin(_bob_offset) * _bob_amplitude

	# Slow rotation
	rotation += delta * _rotate_speed

	# Glow pulse
	if _glow:
		var pulse = (sin(_bob_offset * 2.0) + 1.0) / 2.0
		_glow.modulate.a = 0.3 + pulse * 0.3

	# Scroll left
	if _main and _main.has_method("get_scroll_speed"):
		position.x -= _main.get_scroll_speed() * delta


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() and area.get_parent().has_method("activate_powerup"):
		_collect()


func set_powerup_type(type: String) -> void:
	powerup_type = type
	_apply_visual()


func set_level(level: String) -> void:
	_level_name = level
	_apply_visual()


func _apply_visual() -> void:
	# Set icon/texture based on type
	var color := Color.WHITE
	var icon_label := ""

	match powerup_type:
		"rocket":
			color = Color(1.0, 0.3, 0.1)
			icon_label = "🚀"
		"shield":
			color = Color(0.3, 0.5, 1.0)
			icon_label = "🛡️"
		"turbo":
			color = Color(1.0, 0.85, 0.0)
			icon_label = "⚡"
		"fireworks":
			color = Color(1.0, 0.5, 0.1)
			icon_label = "🎆"
		"doubledeck":
			color = Color(0.9, 0.7, 0.2)
			icon_label = "🚌"

	if _sprite:
		_sprite.modulate = color

	if _glow:
		_glow.modulate = color


func _collect() -> void:
	visible = false
	monitoring = false
	collected.emit(powerup_type)

	# Notify main
	if _main and _main.has_signal("powerup_collected"):
		_main.powerup_collected.emit(powerup_type)

	# Notify bus directly
	var area = get_node_or_null("..")
	if area and area.has_method("activate_powerup"):
		area.activate_powerup(powerup_type)

	queue_free()
