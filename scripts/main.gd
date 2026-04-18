extends Node2D

# ============================================================================
# Ken Bus Adventure — Main Game Controller
# ============================================================================
# State machine: INTRO → PLAYING → PAUSED → GAME_OVER / LEVEL_COMPLETE
# Handles: scrolling, spawning obstacles/kids/powerups, level progression,
#          score, lives, speed scaling, object pooling
# ============================================================================

signal kids_collected_changed(count: int)
signal score_changed(score: int)
signal lives_changed(lives: int)
signal game_over
signal level_complete(level_name: String)
signal state_changed(new_state: GameState)

enum GameState { INTRO, PLAYING, PAUSED, GAME_OVER, LEVEL_COMPLETE }

# --------------------------------------------------------------------------
# EXPORT VARIABLES
# --------------------------------------------------------------------------
@export var bus_scene: PackedScene
@export var obstacle_scene: PackedScene
@export var kid_scene: PackedScene
@export var powerup_scene: PackedScene

# Scroll & Timing
@export var base_scroll_speed: float = 150.0      # px/s
@export var scroll_speed_increment: float = 0.05   # +5% every 30s
@export var level_duration: float = 180.0         # seconds per level

# Spawning
@export var obstacle_spawn_interval: float = 2.0  # base seconds
@export var obstacle_spawn_min: float = 0.8        # minimum spawn interval
@export var kid_spawn_interval: float = 3.5        # seconds between kids
@export var powerup_spawn_interval: float = 12.0   # seconds between powerups
@export var max_kids_on_screen: int = 5
@export var max_obstacles_on_screen: int = 20

# Game balance
@export var kids_to_complete: int = 10             # kids needed per level
@export var starting_lives: int = 3

# --------------------------------------------------------------------------
# INTERNAL STATE
# --------------------------------------------------------------------------
var _state: GameState = GameState.INTRO
var _level_name: String = "citta"
var _elapsed_level_time: float = 0.0
var _elapsed_total_time: float = 0.0
var _current_scroll_speed: float = base_scroll_speed
var _current_spawn_interval: float = obstacle_spawn_interval
var _kids_collected: int = 0
var _score: int = 0
var _lives: int = starting_lives
var _current_level_index: int = 0

var _obstacle_pool: Array[Area2D] = []
var _kids_pool: Array[Area2D] = []
var _powerup_pool: Array[Array] = []  # [scene_instance, type]

var _obstacle_spawn_timer: float = 0.0
var _kid_spawn_timer: float = 0.0
var _powerup_spawn_timer: float = 0.0

var _bus: CharacterBody2D = null
var _hud: CanvasLayer = null

const LEVELS: Array[String] = ["scuola", "citta", "bosco", "luna"]
const LEVEL_SCORES: Array[int] = [0, 500, 1500, 3000]

# ============================================================================
# LIFECYCLE
# ============================================================================
func _ready() -> void:
	# Pre-populate obstacle pool
	for i in range(max_obstacles_on_screen):
		var obs = obstacle_scene.instantiate()
		obs.visible = false
		obs.monitoring = false
		add_child(obs)
		_obstacle_pool.append(obs)

	# Pre-populate kids pool
	for i in range(max_kids_on_screen):
		var kid = kid_scene.instantiate()
		kid.visible = false
		kid.monitoring = false
		add_child(kid)
		_kids_pool.append(kid)

	_change_state(GameState.INTRO)


func _process(delta: float) -> void:
	if _state == GameState.PLAYING:
		_elapsed_level_time += delta
		_elapsed_total_time += delta
		_update_difficulty()
		_spawn_logic(delta)
		_cleanup_off_screen()
		_check_level_complete()


# ============================================================================
# STATE MACHINE
# ============================================================================
func _change_state(new_state: GameState) -> void:
	var prev_state = _state
	_state = new_state
	state_changed.emit(new_state)

	match new_state:
		GameState.INTRO:
			_show_intro_screen()
		GameState.PLAYING:
			if prev_state == GameState.INTRO or prev_state == GameState.LEVEL_COMPLETE:
				_start_level(_level_name)
			elif prev_state == GameState.PAUSED:
				pass  # resume
		GameState.PAUSED:
			_show_pause_screen()
		GameState.GAME_OVER:
			_show_game_over_screen()
		GameState.LEVEL_COMPLETE:
			_show_level_complete_screen()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _state == GameState.PLAYING:
			_change_state(GameState.PAUSED)
		elif _state == GameState.PAUSED:
			_change_state(GameState.PLAYING)


# ============================================================================
# LEVEL MANAGEMENT
# ============================================================================
func _start_level(level_name: String) -> void:
	_level_name = level_name
	_elapsed_level_time = 0.0
	_current_scroll_speed = base_scroll_speed
	_current_spawn_interval = obstacle_spawn_interval
	_obstacle_spawn_timer = 1.5  # first obstacle soon
	_kid_spawn_timer = 0.5       # first kid soon
	_powerup_spawn_timer = randf_range(5.0, 10.0)  # first powerup

	# Spawn bus if not exists
	if not _bus:
		_bus = bus_scene.instantiate()
		add_child(_bus)
		_bus.tree_exited.connect(_on_bus_tree_exited)

	# Reset collected kids but keep score/lives
	_kids_collected = 0
	kids_collected_changed.emit(_kids_collected)

	# Apply level background
	_update_level_background()


func _update_level_background() -> void:
	var bg = $Background
	if bg:
		match _level_name:
			"scuola":
				bg.modulate = Color(0.53, 0.81, 0.92)  # blue sky
			"citta":
				bg.modulate = Color(0.85, 0.75, 0.65)  # urban haze
			"bosco":
				bg.modulate = Color(0.45, 0.75, 0.45)  # green forest
			"luna":
				bg.modulate = Color(0.4, 0.35, 0.6)   # purple space
		if bg.has_method("set_level"):
			bg.set_level(_level_name)

func _update_spawners_level() -> void:
	var obstacle_spawner = $ObstacleSpawner
	var kid_spawner = $KidSpawner
	if obstacle_spawner and obstacle_spawner.has_method("set_level"):
		obstacle_spawner.set_level(_level_name)
	if kid_spawner and kid_spawner.has_method("set_level"):
		kid_spawner.set_level(_level_name)

func _check_level_advancement() -> void:
	var next_idx = _current_level_index + 1
	if next_idx >= LEVELS.size():
		_trigger_victory()
		return
	if _score >= LEVEL_SCORES[next_idx]:
		_advance_to_level(next_idx)

func _advance_to_level(idx: int) -> void:
	_current_level_index = idx
	_level_name = LEVELS[idx]
	# Clear all active objects
	for obs in _obstacle_pool:
		if obs.visible:
			_release_obstacle(obs)
	for kid in _kids_pool:
		if kid.visible:
			_release_kid(kid)
	for entry in _powerup_pool:
		var p = entry[0]
		if is_instance_valid(p):
			p.queue_free()
	_powerup_pool.clear()
	# Reset timers
	_obstacle_spawn_timer = 1.5
	_kid_spawn_timer = 0.5
	_powerup_spawn_timer = randf_range(5.0, 10.0)
	# Apply new level
	_update_level_background()
	_update_spawners_level()
	level_complete.emit(_level_name)
	_change_state(GameState.LEVEL_COMPLETE)

func _trigger_victory() -> void:
	_current_level_index = 0
	_change_state(GameState.GAME_OVER)


func _update_difficulty() -> void:
	# Speed scaling: +5% every 30 seconds
	var speed_mult = 1.0 + (_elapsed_level_time / 30.0) * scroll_speed_increment
	_current_scroll_speed = base_scroll_speed * speed_mult

	# Spawn rate scaling: -0.1s every 30 seconds (min 0.8s)
	var spawn_reduction = (_elapsed_level_time / 30.0) * 0.1
	_current_spawn_interval = max(obstacle_spawn_min, obstacle_spawn_interval - spawn_reduction)


func _check_level_complete() -> void:
	if _elapsed_level_time >= level_duration:
		if _kids_collected >= kids_to_complete:
			_advance_level()
		else:
			_change_state(GameState.GAME_OVER)


func _advance_level() -> void:
	# Called when time runs out with enough kids
	if _kids_collected >= kids_to_complete:
		_advance_to_level(_current_level_index + 1)
	else:
		_change_state(GameState.GAME_OVER)


# ============================================================================
# SPAWNING
# ============================================================================
func _spawn_logic(delta: float) -> void:
	_obstacle_spawn_timer -= delta
	_kid_spawn_timer -= delta
	_powerup_spawn_timer -= delta

	if _obstacle_spawn_timer <= 0:
		_spawn_obstacle()
		_obstacle_spawn_timer = _current_spawn_interval + randf_range(-0.3, 0.3)

	if _kid_spawn_timer <= 0 and _get_active_kids_count() < max_kids_on_screen:
		_spawn_kid()
		_kid_spawn_timer = kid_spawn_interval + randf_range(-0.5, 1.0)

	if _powerup_spawn_timer <= 0:
		_spawn_powerup()
		_powerup_spawn_timer = powerup_spawn_interval + randf_range(-2.0, 2.0)


func _spawn_obstacle() -> void:
	var obs = _get_inactive_obstacle()
	if not obs:
		return

	var vp_w = get_viewport_rect().size.x
	obs.global_position = Vector2(vp_w + 50, _get_road_y())
	obs.visible = true
	obs.monitoring = true
	obs.tree_exited.connect(_on_obstacle_tree_exited.bind(obs))

	# Configure obstacle type based on level
	if obs.has_method("set_level"):
		obs.set_level(_level_name)


func _spawn_kid() -> void:
	var kid = _get_inactive_kid()
	if not kid:
		return

	var vp_w = get_viewport_rect().size.x
	var road_y = _get_road_y()
	kid.global_position = Vector2(vp_w + 30, road_y - 20)
	kid.visible = true
	kid.monitoring = true
	kid.tree_exited.connect(_on_kid_tree_exited.bind(kid))

	if kid.has_method("set_level"):
		kid.set_level(_level_name)


func _spawn_powerup() -> void:
	var powerup = powerup_scene.instantiate()
	add_child(powerup)
	var vp_w = get_viewport_rect().size.x
	powerup.global_position = Vector2(vp_w + 30, _get_road_y() - 30)

	var types = ["rocket", "shield", "turbo", "fireworks", "doubledeck"]
	var rng_type = types[randi() % types.size()]
	if powerup.has_method("set_powerup_type"):
		powerup.set_powerup_type(rng_type)

	_powerup_pool.append([powerup, rng_type])


func _get_road_y() -> float:
	# Road is at bottom third of screen
	return get_viewport_rect().size.y * 0.65


func _cleanup_off_screen() -> void:
	var vp_w = get_viewport_rect().size.x
	var cull_x = -100

	for obs in _obstacle_pool:
		if obs.visible and obs.global_position.x < cull_x:
			_release_obstacle(obs)

	for kid in _kids_pool:
		if kid.visible and kid.global_position.x < cull_x:
			_release_kid(kid)


# ============================================================================
# OBJECT POOLING
# ============================================================================
func _get_inactive_obstacle() -> Area2D:
	for obs in _obstacle_pool:
		if not obs.visible:
			return obs
	# Overflow: instantiate
	var overflow = obstacle_scene.instantiate()
	add_child(overflow)
	_obstacle_pool.append(overflow)
	return overflow


func _release_obstacle(obs: Area2D) -> void:
	obs.visible = false
	obs.monitoring = false
	if obs.tree_exited.is_connected(_on_obstacle_tree_exited.bind(obs)):
		obs.tree_exited.disconnect(_on_obstacle_tree_exited.bind(obs))


func _get_inactive_kid() -> Area2D:
	for kid in _kids_pool:
		if not kid.visible:
			return kid
	var overflow = kid_scene.instantiate()
	add_child(overflow)
	_kids_pool.append(overflow)
	return overflow


func _release_kid(kid: Area2D) -> void:
	kid.visible = false
	kid.monitoring = false
	if kid.tree_exited.is_connected(_on_kid_tree_exited.bind(kid)):
		kid.tree_exited.disconnect(_on_kid_tree_exited.bind(kid))


func _get_active_kids_count() -> int:
	var count = 0
	for kid in _kids_pool:
		if kid.visible:
			count += 1
	return count


# ============================================================================
# SIGNALS / CALLBACKS
# ============================================================================
func _on_bus_tree_exited() -> void:
	_lives -= 1
	lives_changed.emit(_lives)
	if _lives <= 0:
		_change_state(GameState.GAME_OVER)
	else:
		# Respawn bus after delay
		await get_tree().create_timer(1.5).timeout
		if _state == GameState.PLAYING:
			_bus = bus_scene.instantiate()
			add_child(_bus)
			_bus.tree_exited.connect(_on_bus_tree_exited)


func _on_obstacle_tree_exited(obs: Area2D) -> void:
	_release_obstacle(obs)


func _on_kid_tree_exited(kid: Area2D) -> void:
	_release_kid(kid)


func _on_kid_collected() -> void:
	_kids_collected += 1
	_score += 100
	kids_collected_changed.emit(_kids_collected)
	score_changed.emit(_score)
	_check_level_advancement()


func _on_obstacle_destroyed() -> void:
	_score += 50
	score_changed.emit(_score)


func _on_powerup_collected(type: String) -> void:
	_score += 200
	score_changed.emit(_score)
	if _bus and _bus.has_method("activate_powerup"):
		_bus.activate_powerup(type)


# ============================================================================
# UI SCREENS
# ============================================================================
func _show_intro_screen() -> void:
	# TODO: show title screen, await tap to start
	pass


func _show_pause_screen() -> void:
	# TODO: overlay pause menu
	get_tree().paused = true


func _show_game_over_screen() -> void:
	get_tree().paused = false
	# TODO: show game over screen with score
	pass


func _show_level_complete_screen() -> void:
	get_tree().paused = false
	# Show level complete info via HUD if available
	var hud = $HUD
	if hud and hud.has_method("show_level_complete"):
		hud.show_level_complete(_level_name, _score, _kids_collected)
	# Auto-advance after delay
	await get_tree().create_timer(3.0).timeout
	if _state == GameState.LEVEL_COMPLETE:
		_change_state(GameState.PLAYING)


# ============================================================================
# PUBLIC API
# ============================================================================
func get_scroll_speed() -> float:
	return _current_scroll_speed


func get_game_state() -> GameState:
	return _state


func start_game() -> void:
	if _state == GameState.INTRO or _state == GameState.GAME_OVER:
		_kids_collected = 0
		_score = 0
		_lives = starting_lives
		_current_level_index = 0
		_level_name = LEVELS[0]
		_score = 0
		score_changed.emit(_score)
		lives_changed.emit(_lives)
		kids_collected_changed.emit(_kids_collected)
		_update_spawners_level()
		_change_state(GameState.PLAYING)
