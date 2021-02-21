extends PlayerFiniteStateMachineNode

func start_state():
	player_node.set_animation("walk")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_floor_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION * player_node.RUN_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_flashlight_once:
		return player_node.fsm.state_nodes.toggle_flashlight
	if player_node.input_jump_once and player_node.is_able_to_jump():
		return player_node.fsm.state_nodes.jump
	if player_node.input_velocity.x != 0 and player_node.has_invert_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.floor_turn
	if player_node.input_velocity.x != 0 and player_node.is_on_wall():
		return player_node.fsm.state_nodes.push_wall
	if player_node.input_velocity.x == 0 and player_node.velocity.x != 0:
		return player_node.fsm.state_nodes.skid
	if player_node.input_velocity.x == 0 and player_node.velocity.x == 0:
		return player_node.fsm.state_nodes.stand
