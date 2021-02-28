extends EntitySpawner

# @override
func spawn(position: Vector2, parent_node: Node, _spawn_property_list: Dictionary):
	var key_node = load("res://Game/Entities/Scenes/Pickups/Key.tscn").instance()
	key_node.position = position
	parent_node.add_child(key_node)

# @override
func get_spawner_property_list() -> Array:
	var property_list := []
	property_list.append({
		"name": "key/key_id",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ScriptHelpers.dic_string_join(Constants.KeyId),
	})
	return property_list
