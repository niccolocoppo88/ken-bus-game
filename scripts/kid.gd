extends Area2D

# ============================================================================
# Ken Bus Adventure — Kid Collectible
# ============================================================================
# Spawns on road, waves, collects on bus contact
# Visual: yellow helmet, 2-frame wave animation
# ============================================================================

signal collected

@export var kid_type: String = "wave"
@export var collect_points: int = 100

var _level_name: String = "citta"
var _main: Node2D = null
var _animated_sprite: AnimatedSprite2D = null
var _bob_offset: float = 0.0
var _base_y: float = 0.0
var _collected: bool = false

func _ready() -> void:
	_main = get_parent()
	area_entered.connect(_on_area_entered)

	_animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

	# Set collision layer to Kids (layer 3)
	collision_layer = (1 << 2)
	collision_mask = 0

	_base_y = position.y
	_apply_level_visuals()


func _process(delta: float) -> void:
	if _collected:
		return

	# Sine wave bob
	_bob_offset += delta * 3.0
	position.y = _base_y + sin(_bob_offset) * 5.0

	# Scroll left
	if _main and _main.has_method("get_scroll_speed"):
		position.x -= _main.get_scroll_speed() * delta


func _on_area_entered(area: Area2D) -> void:
	# Check if bus
	if area.get_parent() and area.get_parent().has_method("is_invincible") or area.name == "BusHitbox":
		_collect()


func set_level(level: String) -> void:
	_level_name = level
	_apply_level_visuals()


func _apply_level_visuals() -> void:
	if _animated_sprite:
		_animated_sprite.play("wave")


func _collect() -> void:
	if _collected:
		return
	_collected = true

	# Shrink + fly toward bus animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)

	await tween.finished

	visible = false
	monitoring = false
	collected.emit()
	queue_free()
