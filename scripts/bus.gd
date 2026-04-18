extends CharacterBody2D

# ============================================================================
# Ken Bus Adventure — Bus Controller
# ============================================================================
# Handles: vertical movement (up/down), punch mechanic, power-up activation,
#          Ken animation, invincibility state
# ============================================================================

signal punch_executed
signal punch_hit(obstacle)

# --------------------------------------------------------------------------
# EXPORT VARIABLES
# --------------------------------------------------------------------------
@export var move_speed: float = 300.0          # vertical movement speed
@export var punch_cooldown: float = 1.5         # seconds between punches
@export var punch_hitbox_duration: float = 0.2 # how long hitbox is active
@export var punch_hitbox_width: float = 128.0
@export var punch_hitbox_height: float = 128.0

# --------------------------------------------------------------------------
# INTERNAL STATE
# --------------------------------------------------------------------------
var _can_punch: bool = true
var _is_punching: bool = false
var _punch_hitbox: Area2D = null
var _punch_cooldown_timer: float = 0.0
var _active_powerup: String = ""
var _powerup_timer: float = 0.0
var _is_invincible: bool = false
var _powerup_sprite: Sprite2D = null

var _main: Node2D = null
var _animated_sprite: AnimatedSprite2D = null

const MOVE_UP := "up"
const MOVE_DOWN := "down"

# ============================================================================
# LIFECYCLE
# ============================================================================
func _ready() -> void:
	_main = get_parent()
	_animated_sprite = $AnimatedSprite2D

	_setup_punch_hitbox()
	_setup_powerup_sprite()

	# Connect to main signals
	if _main.has_signal("kids_collected_changed"):
		_main.kids_collected_changed.connect(_on_kids_collected_changed)


func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_punch_input()
	_handle_punch_cooldown(delta)
	_handle_powerup_timer(delta)
	_apply_visual_state()


# ============================================================================
# MOVEMENT
# ============================================================================
func _handle_movement(delta: float) -> void:
	var direction := 0.0

	if Input.is_action_pressed(MOVE_UP):
		direction = -1.0
	elif Input.is_action_pressed(MOVE_DOWN):
		direction = 1.0

	if direction != 0.0:
		position.y += direction * move_speed * delta
		# Clamp to road bounds
		var vp_h = get_viewport_rect().size.y
		position.y = clamp(position.y, vp_h * 0.45, vp_h * 0.75)


# ============================================================================
# PUNCH MECHANIC
# ============================================================================
func _handle_punch_input() -> void:
	if Input.is_action_pressed("punch") and _can_punch and not _is_punching:
		_execute_punch()


func _execute_punch() -> void:
	_is_punching = true
	_can_punch = false
	_punch_cooldown_timer = punch_cooldown

	# Activate hitbox
	if _punch_hitbox:
		_punch_hitbox.monitoring = true
		_punch_hitbox.visible = true

	# Animation
	if _animated_sprite:
		_animated_sprite.play("punch")

	punch_executed.emit()

	# Schedule hitbox deactivation
	await get_tree().create_timer(punch_hitbox_duration).timeout
	_deactivate_hitbox()


func _deactivate_hitbox() -> void:
	if _punch_hitbox:
		_punch_hitbox.monitoring = false
		_punch_hitbox.visible = false
	_is_punching = false


func _handle_punch_cooldown(delta: float) -> void:
	if _punch_cooldown_timer > 0:
		_punch_cooldown_timer -= delta
		if _punch_cooldown_timer <= 0:
			_can_punch = true


# ============================================================================
# POWERUP SYSTEM
# ============================================================================
func activate_powerup(type: String) -> void:
	_active_powerup = type
	_powerup_timer = _get_powerup_duration(type)
	_is_invincible = true  # all powerups give some invincibility

	match type:
		"rocket":
			# Speed boost is handled by main.gd scroll speed
			pass
		"shield":
			# Visual: blue aura
			_add_aura("shield")
		"turbo":
			# Visual: speed lines
			_add_aura("turbo")
		"fireworks":
			_clear_all_obstacles()
		"doubledeck":
			# Visual: bus stretches vertically
			_scale_bus(1.0, 2.0)

	# Update HUD
	_update_powerup_display(type)


func _handle_powerup_timer(delta: float) -> void:
	if _powerup_timer > 0:
		_powerup_timer -= delta
		if _powerup_timer <= 0:
			_deactivate_powerup()


func _deactivate_powerup() -> void:
	_active_powerup = ""
	_is_invincible = false
	_remove_aura()
	_reset_bus_scale()
	_clear_powerup_display()


func _get_powerup_duration(type: String) -> float:
	match type:
		"rocket":   return 5.0
		"shield":   return 8.0
		"turbo":    return 6.0
		"fireworks": return 0.0  # instant
		"doubledeck": return 10.0
	return 5.0


func _clear_all_obstacles() -> void:
	if _main:
		_main.clear_all_obstacles()


# ============================================================================
# VISUAL HELPERS
# ============================================================================
func _apply_visual_state() -> void:
	if not _animated_sprite:
		return

	if _is_punching:
		return  # animation override

	if not _can_punch:
		_animated_sprite.play("punch_cooldown")
	else:
		_animated_sprite.play("idle")


func _setup_punch_hitbox() -> void:
	_punch_hitbox = Area2D.new()
	_punch_hitbox.name = "PunchHitbox"
	_punch_hitbox.monitoring = false
	_punch_hitbox.visible = false

	# Collision shape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(punch_hitbox_width, punch_hitbox_height)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	_punch_hitbox.add_child(collision)

	# Position: to the right of the bus
	_punch_hitbox.position = Vector2(80, 0)

	# Collision layers/masks
	_punch_hitbox.collision_layer = 0
	_punch_hitbox.collision_mask = (1 << 1)  # layer 2 = Obstacles

	# Connect signal
	_punch_hitbox.area_entered.connect(_on_punch_hitbox_area_entered.bind(_punch_hitbox))

	add_child(_punch_hitbox)


func _on_punch_hitbox_area_entered(area: Area2D, hitbox: Area2D) -> void:
	if hitbox.get_collision_layer_value(2):  # Obstacles layer
		var obstacle = area.get_parent()
		if obstacle and obstacle.has_method("destroy"):
			obstacle.destroy()
			punch_hit.emit(obstacle)
			_screen_shake(0.1, 4.0)


func _screen_shake(duration: float, intensity: float) -> void:
	# TODO: implement camera shake via SceneTreeTween
	pass


func _setup_powerup_sprite() -> void:
	_powerup_sprite = Sprite2D.new()
	_powerup_sprite.name = "PowerupAura"
	_powerup_sprite.visible = false
	add_child(_powerup_sprite)


func _add_aura(type: String) -> void:
	if _powerup_sprite:
		_powerup_sprite.visible = true
		# TODO: load appropriate aura texture
		match type:
			"shield":
				_powerup_sprite.modulate = Color(0.3, 0.5, 1.0, 0.4)
			"turbo":
				_powerup_sprite.modulate = Color(1.0, 0.8, 0.0, 0.4)


func _remove_aura() -> void:
	if _powerup_sprite:
		_powerup_sprite.visible = false


func _scale_bus(scale_x: float, scale_y: float) -> void:
	scale = Vector2(scale_x, scale_y)


func _reset_bus_scale() -> void:
	scale = Vector2(1.0, 1.0)


func _update_powerup_display(type: String) -> void:
	# Signal to HUD
	if _main and _main.has_signal("powerup_activated"):
		_main.powerup_activated.emit(type)


func _clear_powerup_display() -> void:
	if _main and _main.has_signal("powerup_deactivated"):
		_main.powerup_deactivated.emit()


# ============================================================================
# SIGNAL CALLBACKS
# ============================================================================
func _on_kids_collected_changed(count: int) -> void:
	# Could play a sound or animation here
	pass


# ============================================================================
# PUBLIC API
# ============================================================================
func is_invincible() -> bool:
	return _is_invincible


func get_active_powerup() -> String:
	return _active_powerup
