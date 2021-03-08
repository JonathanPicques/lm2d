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
var _spawner_properties := []

export(Constants.ChestId) var chest_id: int
export var spawner_script: GDScript setget set_spawner_script, get_spawner_script

func set_spawner_script(script: GDScript):
	if script == null:
		_spawner = null
		_spawner_script = null
		_spawner_properties.clear()
	else:
		var spawner = script.new()
		if spawner is EntitySpawner:
			_spawner = spawner
			_spawner_script = script
			_spawner_properties = spawner.get_spawner_property_list()
			for spawner_property in _spawner_properties:
				if spawner_property.has("default_value"):
					set(spawner_property.name, spawner_property.default_value)
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
	return _spawner_properties

###
# Process
###

var opened := false

# @impure
func _ready():
	opened = GameState.is_chest_opened(chest_id) if not Engine.editor_hint else false
	if opened:
		$Area2D.set_deferred("monitorable", false)
		$AnimatedSprite.play("opened")

###
# Interactions
###

# @override
func can_interact() -> bool:
	return not opened

# @override
func on_interact():
	opened = true
	$Area2D.set_deferred("monitorable", false)
	$AnimatedSprite.play("opened")
	$AudioStreamPlayer2D.play()
	if _spawner:
		_spawner.connect("spawn_finished", self, "on_spawn_finished")
		_spawner.spawn($SpawnPoint.global_position, get_parent(), _properties)

# on_spawn_finished is called when the spawner finished and save this chest was opened.
# @impure
func on_spawn_finished():
	GameState.open_chest(chest_id)
