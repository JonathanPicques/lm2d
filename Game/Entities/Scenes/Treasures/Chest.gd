extends EntityNode

var opened := false

###
# Nodes
###

onready var ChestNode: Node2D = $"."
onready var ChestSprite: Node2D = $AnimatedSprite
onready var ChestSpawnPoint: Node2D = $SpawnPoint

###
# Config
###

# Chest is revealed.
export var revealed := false

# Chest is only visible through this light.
export(Constants.LightType, FLAGS) var reveal_to_light_types = Constants.LightType.Normal

# Chest will spawn this scene when opened.
export var scene_to_spawn: PackedScene
export var scene_to_spawn_count: int
export var scene_to_spawn_delay: float
export var scene_to_spawn_offset: Vector2
export var scene_to_spawn_interval: float

###
# Chest reacts to light
###

func _ready():
	if not revealed:
		# set light masks
		ChestNode.light_mask = reveal_to_light_types
		ChestSprite.light_mask = reveal_to_light_types
		# set visibility
		ChestSprite.self_modulate.a = 0.0
		ChestSprite.use_parent_material = true

# @override
func can_be_lit(light_type: int):
	return (light_type & reveal_to_light_types) == light_type

# @override
func on_light_process(delta: float, _light_type: int):
	ChestSprite.self_modulate.a = move_toward(ChestSprite.self_modulate.a, 1.0, delta)
	if not revealed and ChestSprite.self_modulate.a == 1.0:
		revealed = true
		ChestNode.material.light_mode = 0 # LIGHT_MODE_NORMAL
		ChestNode.light_mask = Constants.LightTypeAll
		ChestSprite.light_mask = Constants.LightTypeAll

# @override
func on_light_finish(_light_type: int):
	if not revealed:
		ChestSprite.self_modulate.a = 0.0

###
# Chest interaction
###

# @override
func can_interact() -> bool:
	return revealed and not opened

# @override
func on_interact():
	opened = true
	ChestSprite.play("opened")
	var spawn_node := scene_to_spawn.instance()
	spawn_node.position = ChestSpawnPoint.global_position + scene_to_spawn_offset
	get_parent().add_child(spawn_node)
