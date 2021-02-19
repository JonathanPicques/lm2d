extends Node2D
class_name EntityNode

###
# Player interactions
###

# can_interact returns whether the player can interact with this entity.
# @pure
func can_interact() -> bool:
	return false

# on_interact is called when the player presses the "use" button while overlapping this entity.
# @impure
func on_interact():
	pass

###
# Lighting (react to light or spectral light)
###

var lit_time := 0.0

# can_be_lit returns whether the player can lit this entity.
# @param light_type - Constants.LightType
# @pure
func can_be_lit(light_type: int) -> bool:
	return false

# on_light_start is called when the player's light enters this entity.
# @param light_type - Constants.LightType
# @impure
func on_light_start(light_type: int):
	pass

# on_light_process is called when the player's light collides with this entity.
# @param light_type - Constants.LightType
# @impure
func on_light_process(delta: float, light_type: int):
	lit_time += delta

# on_light_finish is called when the player's light leaves this entity.
# @param light_type - Constants.LightType
# @impure
func on_light_finish(light_type: int):
	pass

###
# Player vacuuming
###

var vacuum_time := 0.0

# on_vacuum_start is called when the player's vacuum enters this entity.
# @impure
func on_vacuum_start():
	vacuum_time = 0.0

# on_vacuum_process is called when the player's vacuum collides with this entity.
# @impure
func on_vacuum_process(delta: float):
	vacuum_time += delta

# on_vacuum_finish is called when the player's vacuum leaves this entity.
# @impure
func on_vacuum_finish():
	vacuum_time = 0.0
