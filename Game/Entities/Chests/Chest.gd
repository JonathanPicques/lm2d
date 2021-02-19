extends EntityNode

###
# Config
###

export(Constants.LightTypes, FLAGS) var react_to_light_types = Constants.LightTypes.Normal

###
# Chest reacts to light
###

var entirely_lit := false

func _ready():
	$".".light_mask = react_to_light_types
	$AnimatedSprite.light_mask = react_to_light_types
	$AnimatedSprite.self_modulate.a = 0.0
	$AnimatedSprite.use_parent_material = true

# @override
func can_be_lit(light_type: int):
	return (light_type & react_to_light_types) == light_type

# @override
func on_light_process(delta: float, light_type: int):
	$AnimatedSprite.self_modulate.a = move_toward($AnimatedSprite.self_modulate.a, 1.0, delta)
	if not entirely_lit and $AnimatedSprite.self_modulate.a == 1.0:
		entirely_lit = true
		$".".material.light_mode = 0 # LIGHT_MODE_NORMAL
		$".".light_mask = Constants.LightTypes.Normal | Constants.LightTypes.Spectral
		$AnimatedSprite.light_mask = Constants.LightTypes.Normal | Constants.LightTypes.Spectral

# @override
func on_light_finish(light_type: int):
	if not entirely_lit:
		$AnimatedSprite.self_modulate.a = 0.0
