extends EntityNode
class_name EntityPickupNode

signal picked_up()

# can_be_picked_up returns whether the player can pickup this entity.
# @pure
func can_be_picked_up() -> bool:
	return false

# on_pickup is called when the player overlaps this entity.
# @impure
func on_pickup():
	pass
