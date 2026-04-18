extends CanvasLayer

# ============================================================================
# Ken Bus Adventure — HUD
# ============================================================================
# Top-left: Kids collected (icon + number)
# Top-right: Score
# Top-center: Lives (hearts)
# Bottom-center: Active power-up slot
# ============================================================================

@export var kids_icon_path: NodePath
@export var kids_label_path: NodePath
@export var score_label_path: NodePath
@export var lives_container_path: NodePath
@export var powerup_slot_path: NodePath

var _kids_count: int = 0
var _score: int = 0
var _lives: int = 3
var _active_powerup: String = ""

var _kids_label: Label = null
var _score_label: Label = null
var _lives_container: HBoxContainer = null
var _powerup_slot: TextureRect = null

func _ready() -> void:
	_get_nodes()
	_update_all()


func _get_nodes() -> void:
	_kids_label = get_node_or_null(kids_label_path)
	_score_label = get_node_or_null(score_label_path)
	_lives_container = get_node_or_null(lives_container_path)
	_powerup_slot = get_node_or_null(powerup_slot_path)


func _process(delta: float) -> void:
	pass


# ============================================================================
# PUBLIC UPDATE METHODS (called by main via signals)
# ============================================================================
func update_kids(count: int) -> void:
	_kids_count = count
	if _kids_label:
		_kids_label.text = str(count)


func update_score(score: int) -> void:
	_score = score
	if _score_label:
		_score_label.text = str(score)


func update_lives(lives: int) -> void:
	_lives = lives
	_update_lives_display()


func show_powerup(type: String) -> void:
	_active_powerup = type
	if _powerup_slot:
		_powerup_slot.visible = true
		# TODO: set icon texture based on type
		var icon_label = ""
		match type:
			"rocket":    icon_label = "🚀"
			"shield":   icon_label = "🛡️"
			"turbo":    icon_label = "⚡"
			"fireworks":icon_label = "🎆"
			"doubledeck": icon_label = "🚌"


func hide_powerup() -> void:
	_active_powerup = ""
	if _powerup_slot:
		_powerup_slot.visible = false


func _update_all() -> void:
	update_kids(_kids_count)
	update_score(_score)
	update_lives(_lives)


func _update_lives_display() -> void:
	if not _lives_container:
		return

	# Clear existing hearts
	for child in _lives_container.get_children():
		child.queue_free()

	# Add new hearts
	for i in range(_lives):
		var heart = TextureRect.new()
		heart.custom_minimum_size = Vector2(24, 24)
		# TODO: set heart texture
		_lives_container.add_child(heart)
