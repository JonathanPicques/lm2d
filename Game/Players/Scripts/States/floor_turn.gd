extends PlayerFiniteStateMachineNode

func start_state():
	player_node.set_animation("floor_turn")
	if player_node.velocity.x == 0:
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.walk

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.RUN_DECELERATION * player_node.RUN_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump_once and player_node.is_able_to_jump():
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.jump
	if player_node.has_same_direction(player_node.velocity.x, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.walk
	if player_node.velocity.x == 0 or player_node.is_on_wall():
		player_node.velocity.x = 0.0
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.stand
