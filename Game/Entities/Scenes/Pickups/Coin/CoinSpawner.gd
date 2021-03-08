tool
extends EntitySpawner

const PROPERTY_COIN_DELAY = "coin/coin_delay"
const PROPERTY_COIN_AMOUNT = "coin/coin_amount"

# @override
func spawn(position: Vector2, parent_node: Node, spawn_property_list: Dictionary):
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = spawn_property_list[PROPERTY_COIN_DELAY]
	parent_node.add_child(timer)
	emit_signal("spawn_finished")
	for _i in range(0, spawn_property_list[PROPERTY_COIN_AMOUNT]):
		var coin_node: CoinEntityPickupNode = load("res://Game/Entities/Scenes/Pickups/Coin/Coin.tscn").instance()
		coin_node.position = position
		parent_node.add_child(coin_node)
		coin_node.CoinRigidBody2D.apply_impulse(Vector2(0.0, -2.0), Vector2(rand_range(-32.0, 32.0), -128.0))
		timer.start()
		yield(timer, "timeout")
	timer.queue_free()

# @override
func get_spawner_property_list() -> Array:
	var property_list := []
	property_list.append({
		"name": PROPERTY_COIN_DELAY,
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_RANGE,
		"default_value": 0.1
	})
	property_list.append({
		"name": PROPERTY_COIN_AMOUNT,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"default_value": 10
	})
	return property_list
