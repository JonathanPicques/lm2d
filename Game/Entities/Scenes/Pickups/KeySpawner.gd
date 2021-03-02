extends EntitySpawner

const PROPERTY_KEY_ID = "key/key_id"

# @override
func spawn(position: Vector2, parent_node: Node, _spawn_property_list: Dictionary):
	var key_node: KeyEntityPickupNode = load("res://Game/Entities/Scenes/Pickups/Key.tscn").instance()
	key_node.key_id = _spawn_property_list[PROPERTY_KEY_ID]
	key_node.position = position
	parent_node.add_child(key_node)
	key_node.KeyRigidBody2D.apply_impulse(Vector2(0.0, -2.0), Vector2((-1.0 if randf() < 0.5 else 1.0) * rand_range(13.0, 22.0), -120.0))
	yield(key_node, "picked_up")
	emit_signal("spawn_finished")

# @override
func get_spawner_property_list() -> Array:
	var property_list := []
	property_list.append({
		"name": PROPERTY_KEY_ID,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ScriptHelpers.enum_join(Constants.KeyId),
	})
	return property_list
