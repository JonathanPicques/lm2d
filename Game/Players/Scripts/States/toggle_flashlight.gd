extends PlayerFiniteStateMachineNode

func start_state():
	player_node.set_flashlight(not player_node.flashlight)
	return player_node.fsm.prev_state_node
