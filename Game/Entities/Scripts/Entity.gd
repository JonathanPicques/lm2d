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

var lit_pick := false # Helper flag for player

# can_be_lit returns whether the player can lit this entity.
# @param light_type - Constants.LightType
# @pure
func can_be_lit(_light_type: int) -> bool:
	return false

# on_light_start is called when the player's light enters this entity.
# @param light_type - Constants.LightType
# @impure
func on_light_start(_light_type: int):
	pass

# on_light_process is called when the player's light collides with this entity.
# @param light_type - Constants.LightType
# @impure
func on_light_process(_delta: float, _light_type: int):
	pass

# on_light_finish is called when the player's light leaves this entity.
# @param light_type - Constants.LightType
# @impure
func on_light_finish(_light_type: int):
	pass

###
# Player vacuuming
###

# on_vacuum_start is called when the player's vacuum enters this entity.
# @impure
func on_vacuum_start():
	pass

# on_vacuum_process is called when the player's vacuum collides with this entity.
# @impure
func on_vacuum_process(_delta: float):
	pass

# on_vacuum_finish is called when the player's vacuum leaves this entity.
# @impure
func on_vacuum_finish():
	pass
