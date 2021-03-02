extends Object
class_name EntitySpawner

signal spawn_finished()

# spawn entities
# @impure
func spawn(_position: Vector2, _parent_node: Node, _spawn_property_list: Dictionary):
	pass

# get_spawner_property_list returns the list of properties to show in the editor to spawn entities.
# @pure
func get_spawner_property_list() -> Array:
	return []
