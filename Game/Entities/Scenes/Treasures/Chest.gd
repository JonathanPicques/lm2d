extends EntityNode

###
# Config
###

# Chest is only visible through this light.
export(Constants.LightType, FLAGS) var react_to_light_types = Constants.LightType.Normal

# Chest will spawn this scene when opened.
export var scene_to_spawn: PackedScene
export var scene_to_spawn_count: int
export var scene_to_spawn_delay: float
export var scene_to_spawn_interval: float

###
# Chest reacts to light
###

var opened := false
var entirely_lit := false

func _ready():
	# set light masks
	$".".light_mask = react_to_light_types
	$AnimatedSprite.light_mask = react_to_light_types
	# set visibility
	$AnimatedSprite.self_modulate.a = 0.0
	$AnimatedSprite.use_parent_material = true

# @override
func can_be_lit(light_type: int):
	return (light_type & react_to_light_types) == light_type

# @override
func on_light_process(delta: float, _light_type: int):
	$AnimatedSprite.self_modulate.a = move_toward($AnimatedSprite.self_modulate.a, 1.0, delta)
	if not entirely_lit and $AnimatedSprite.self_modulate.a == 1.0:
		entirely_lit = true
		$".".material.light_mode = 0 # LIGHT_MODE_NORMAL
		$".".light_mask = Constants.LightTypeAll
		$AnimatedSprite.light_mask = Constants.LightTypeAll

# @override
func on_light_finish(_light_type: int):
	if not entirely_lit:
		$AnimatedSprite.self_modulate.a = 0.0

###
# Chest interaction
###

# @override
func can_interact() -> bool:
	return entirely_lit and not opened

# @override
func on_interact():
	opened = true
	$AnimatedSprite.play("opened")
