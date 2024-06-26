extends PlayerFiniteStateMachineNode

func start_state():
	player_node.set_animation("fall")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_airborne_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION)
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand if player_node.velocity.x == 0 else player_node.fsm.state_nodes.walk
