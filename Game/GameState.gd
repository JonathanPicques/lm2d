extends Node
class_name GameStateNode

const SAVE_GAME_PATH := "user://save_game.tres"

# Default save
var save := GameSaveResource.new()

###
# Debug
###

func _process(_delta: float):
	if Input.is_action_just_pressed("debug_new_game"):
		new_game()
	elif Input.is_action_just_pressed("debug_load_game"):
		load_game()
	elif Input.is_action_just_pressed("debug_save_game"):
		save_game()
	elif Input.is_action_just_pressed("debug_erase_save"):
		erase_save()

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
	# DEBUG: save luigi position
	save.DEBUG_LUIGI_POS = get_child(0).find_node("Luigi").position
	ResourceSaver.save(SAVE_GAME_PATH, save)

# load_game is called to load the game from a file.
# @impure
func load_game() -> bool:
	var existing_save = ResourceLoader.load(SAVE_GAME_PATH, "", true)
	if existing_save:
		# set the save resource
		save = existing_save
		# load the level from the save
		load_level(save.level_path)
		# DEBUG: load luigi position
		get_child(0).find_node("Luigi").position = save.DEBUG_LUIGI_POS
		return true
	return false

# erase_save erases the save game.
# @impure
func erase_save():
	Directory.new().remove(SAVE_GAME_PATH)

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

###
# Trackable entities
###

func open_chest(chest_id: int):
	if chest_id != Constants.ChestId.CHEST_DYNAMIC:
		save.opened_chests[chest_id] = true

func pickup_key(key_id: int):
	if key_id != Constants.KeyId.KEY_DYNAMIC:
		save.picked_up_keys[key_id] = true

func is_chest_opened(chest_id: int) -> bool:
	if chest_id == Constants.ChestId.CHEST_DYNAMIC:
		return false
	return save.opened_chests.has(chest_id)

func is_key_picked_up(key_id: int) -> bool:
	if key_id == Constants.KeyId.KEY_DYNAMIC:
		return false
	return save.picked_up_keys.has(key_id)
