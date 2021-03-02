extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameState.load_game():
		GameState.new_game()
