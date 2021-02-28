tool
extends EntityNode

###
# Nodes
###

onready var ChestNode: Node2D = $"."
onready var ChestSprite: Node2D = $AnimatedSprite
onready var ChestSpawnPoint: Node2D = $SpawnPoint
onready var ChestAudioStreamPlayer2D: AudioStreamPlayer2D = $AudioStreamPlayer2D

###
# Config
###

var _spawner: EntitySpawner = null
var _spawner_script: GDScript = null
export var spawner_script: GDScript setget set_spawner_script, get_spawner_script

func set_spawner_script(script: GDScript):
	if script == null:
		_spawner = null
		_spawner_script = null
		property_list_changed_notify()
	else:
		var spawner = script.new()
		if spawner is EntitySpawner:
			_spawner = spawner
			_spawner_script = script
			property_list_changed_notify()

func get_spawner_script():
	return _spawner_script

###
# Chest properties
###

var _properties := {}

func _get(property: String):
	if _properties.has(property):
		return _properties[property]
	return null

func _set(property: String, value):
	if _properties.has(property):
		_properties[property] = value
		return true
	_properties[property] = value
	return false

func _get_property_list() -> Array:
	if _spawner:
		return _spawner.get_spawner_property_list()
	return []

###
# Interactions
###

# can_interact returns whether the player can interact with this chest.
# @pure
func can_interact() -> bool:
	return true

# on_interact is called when the player presses the "use" button while overlapping this chest.
# @impure
func on_interact():
	if _spawner:
		_spawner.spawn(position, get_parent(), {})
