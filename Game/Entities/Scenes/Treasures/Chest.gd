extends EntityNode

var opened := false

###
# Nodes
###

onready var ChestNode: Node2D = $"."
onready var ChestSprite: Node2D = $AnimatedSprite
onready var ChestSpawnPoint: Node2D = $SpawnPoint
onready var ChestAudioStreamPlayer2D: AudioStreamPlayer2D = $AudioStreamPlayer2D

###
# Config
###

# Chest is revealed.
export var revealed := false

# Chest is only visible through this light.
export(Constants.LightType, FLAGS) var reveal_to_light_types = Constants.LightType.Normal

# Chest will spawn this scene when opened.
export var scene_to_spawn: PackedScene
export var scene_to_spawn_offset: Vector2

# @impure
func _ready():
	match revealed:
		true: reveal_chest()
		false: hide_chest()

###
# Chest API
###

# @impure
func open_chest():
	opened = true
	ChestSprite.play("opened")
	ChestAudioStreamPlayer2D.play()
	var spawn_node := scene_to_spawn.instance()
	spawn_node.position = ChestSpawnPoint.global_position + scene_to_spawn_offset
	get_parent().add_child(spawn_node)

# @impure
func hide_chest():
	revealed = false
	ChestNode.light_mask = reveal_to_light_types
	ChestSprite.light_mask = reveal_to_light_types
	ChestSprite.self_modulate.a = 0.0
	ChestSprite.use_parent_material = true

# @impure
func reveal_chest():
	revealed = true
	ChestNode.material.light_mode = 0 # LIGHT_MODE_NORMAL
	ChestNode.light_mask = Constants.LightTypeAll
	ChestSprite.light_mask = Constants.LightTypeAll
	ChestSprite.self_modulate.a = 1.0
	ChestSprite.use_parent_material = false

###
# Chest reacts to light
###

# @override
# @impure
func can_be_lit(light_type: int):
	return not revealed and (light_type & reveal_to_light_types) == light_type

# @override
# @impure
func on_light_process(delta: float, _light_type: int):
	ChestSprite.self_modulate.a = move_toward(ChestSprite.self_modulate.a, 1.0, delta)
	if not revealed and ChestSprite.self_modulate.a == 1.0:
		reveal_chest()

# @override
# @impure
func on_light_finish(_light_type: int):
	if not revealed:
		hide_chest()

###
# Chest interaction
###

# @override
# @pure
func can_interact() -> bool:
	return revealed and not opened

# @override
# @impure
func on_interact():
	open_chest()
