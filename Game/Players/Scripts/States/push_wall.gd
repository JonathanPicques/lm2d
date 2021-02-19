extends PlayerFiniteStateMachineNode

func start_state():
	player_node.set_animation("skid")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump_once and player_node.is_able_to_jump():
		return player_node.fsm.state_nodes.jump
	if player_node.input_velocity.x == 0 or not player_node.is_on_wall():
		return player_node.fsm.state_nodes.stand
	if player_node.has_invert_direction(player_node.velocity.x, player_node.input_velocity.x):
		player_node.velocity.x = 0.0
		return player_node.fsm.state_nodes.stand
