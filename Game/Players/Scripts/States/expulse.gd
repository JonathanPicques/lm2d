extends PlayerFiniteStateMachineNode

const EXPULSE_DURATION := 0.22

func start_state():
	player_node.handle_expulse()
	player_node.PlayerTween.interpolate_property(player_node.PlayerSprite, "self_modulate", player_node.PlayerSprite.self_modulate, Color.red, EXPULSE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	player_node.PlayerTween.interpolate_property(player_node.PlayerVacuumSprite, "self_modulate", player_node.PlayerVacuumSprite.self_modulate, Color.red, EXPULSE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	player_node.PlayerTween.start()

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.RUN_DECELERATION)
	if not player_node.PlayerTween.is_active():
		return player_node.fsm.state_nodes.stand if player_node.is_on_floor() else player_node.fsm.state_nodes.fall

func finish_state():
	player_node.PlayerTween.interpolate_property(player_node.PlayerSprite, "self_modulate", player_node.PlayerSprite.self_modulate, Color.white, EXPULSE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	player_node.PlayerTween.interpolate_property(player_node.PlayerVacuumSprite, "self_modulate", player_node.PlayerVacuumSprite.self_modulate, Color.white, EXPULSE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	player_node.PlayerTween.start()
