extends Area2D

# ============================================================================
# Ken Bus Adventure — Obstacle
# ============================================================================
# Types: car, barrier, cone, billboard (varies by level)
# Behavior: scroll left, destroy on punch or bus collision
# ============================================================================

signal destroyed

@export var obstacle_type: String = "car"
@export var health: int = 1
@export var points: int = 50

var _level_name: String = "citta"
var _main: Node2D = null
var _sprite: Sprite2D = null
var _animated_sprite: AnimatedSprite2D = null

func _ready() -> void:
	_main = get_parent()
	area_entered.connect(_on_area_entered)

	_sprite = $Sprite2D if has_node("Sprite2D") else null
	_animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

	# Set collision layer to Obstacles (layer 2)
	collision_layer = (1 << 1)
	collision_mask = 0  # we don't detect anything, we ARE detected

	_apply_level_visuals()


func _process(delta: float) -> void:
	if _main and _main.has_method("get_scroll_speed"):
		position.x -= _main.get_scroll_speed() * delta


func _on_area_entered(area: Area2D) -> void:
	# Check if punch hitbox
	if area.name == "PunchHitbox" and area.monitoring:
		destroy()
		return

	# Check if bus
	if area.get_parent() and area.get_parent().has_method("is_invincible"):
		if not area.get_parent().is_invincible():
			destroy()


func set_level(level: String) -> void:
	_level_name = level
	_apply_level_visuals()


func _apply_level_visuals() -> void:
	# Obstacle type selection based on level
	var type_for_level = _get_obstacle_type_for_level()
	obstacle_type = type_for_level

	# Update sprite/animation
	if _animated_sprite:
		_animated_sprite.play(obstacle_type)
	elif _sprite:
		# TODO: load appropriate texture for obstacle_type
		pass


func _get_obstacle_type_for_level() -> String:
	var types: Array[String] = []
	match _level_name:
		"scuola":
			types = ["car", "barrier", "cone"]
		"citta":
			types = ["car", "taxi", "barrier", "billboard"]
		"bosco":
			types = ["tree", "rock", "barrier"]
		"luna":
			types = ["meteor", "crater", "satellite"]
	return types[randi() % types.size()]


func destroy() -> void:
	if not visible:
		return

	visible = false
	monitoring = false
	destroyed.emit()

	# Screen shake (via main)
	if _main and _main.has_method("trigger_screen_shake"):
		_main.trigger_screen_shake(0.1, 4.0)

	# Particles (via CPUParticles2D if available)
	var particles = $CPUParticles2D if has_node("CPUParticles2D") else null
	if particles:
		particles.restart()
		await get_tree().create_timer(0.5).timeout

	queue_free()
