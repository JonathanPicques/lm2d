extends Object
class_name PlayerFiniteStateMachineObject

var state_nodes: = {}

var player_node: Node
var prev_state_node: Node
var next_state_node: Node
var current_state_node: Node

func _init(_player_node: Node, _parent_state_node: Node, _initial_state_node: Node):
	player_node = _player_node
	for i in range (0, _parent_state_node.get_child_count()):
		var state_node := _parent_state_node.get_child(i)
		state_node.player_node = _player_node
		state_nodes[state_node.name] = state_node
	set_state_node(_initial_state_node)

func set_state_node(state_node: Node):
	if current_state_node:
		current_state_node.finish_state()
	prev_state_node = current_state_node
	if state_node == null:
		return
	current_state_node = state_node
	var change_state_node = current_state_node.start_state()
	if change_state_node:
		set_state_node(change_state_node)

func process_state_machine(delta: float):
	var change_state_node = current_state_node.process_state(delta)
	if change_state_node:
		set_state_node(change_state_node)
