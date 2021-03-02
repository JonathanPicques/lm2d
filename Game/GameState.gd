extends Node
class_name GameStateNode

const SAVE_GAME_PATH := "user://save_game.tres"

# Default save
var save := GameSaveResource.new()

###
# Debug
###

func _process(delta):
	if Input.is_action_just_pressed("debug_new_game"):
		new_game()
	elif Input.is_action_just_pressed("debug_load_game"):
		load_game()
	elif Input.is_action_just_pressed("debug_save_game"):
		save_game()

###
# Load/Save
###

# new_game starts a fresh game.
# @impure
func new_game():
	# set the save resource
	save = GameSaveResource.new()
	# load the level from the save
	load_level(save.level_path)

# save_game is called to save the game to a file.
# @impure
func save_game():
	ResourceSaver.save(SAVE_GAME_PATH, save)

# load_game is called to load the game from a file.
# @impure
func load_game() -> bool:
	var existing_save = load(SAVE_GAME_PATH)
	if existing_save:
		# set the save resource
		save = existing_save
		# load the level from the save
		load_level(save.level_path)
		return true
	return false

###
# Level
###

# load_level loads the given level and disposes of the previous one.
# @impure
func load_level(level_path: String):
	# remove previous level
	var child_count := get_child_count()
	for i in range(child_count - 1, -1, -1):
		var child := get_child(i)
		remove_child(child)
		child.queue_free()
	# load level
	add_child(load(level_path).instance())
