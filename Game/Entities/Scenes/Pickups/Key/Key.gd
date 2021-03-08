extends EntityPickupNode
class_name KeyEntityPickupNode

###
# Nodes
###

onready var KeyArea2D: Area2D = $Area2D
onready var KeyRigidBody2D: RigidBody2D = $RigidBody2D
onready var KeyAudioStreamPlayer2D: AudioStreamPlayer2D = $RigidBody2D/AudioStreamPlayer2D

###
# Config
###

export(Constants.KeyId) var key_id: int

###
# Process
###

# @impure
func _ready():
	KeyArea2D.set_deferred("monitorable", false)

# @impure
func _process(_delta: float):
	KeyArea2D.position = KeyRigidBody2D.position

# @impure
func on_body_entered(_body: Node):
	if KeyRigidBody2D.linear_velocity.length() > Constants.PhysicsSleepLength:
		KeyAudioStreamPlayer2D.play()
	else:
		KeyArea2D.set_deferred("monitorable", true)

###
# Pickup
###

# @override
func can_be_picked_up() -> bool:
	return true

# @override
func on_pickup():
	GameState.pickup_key(key_id)
	emit_signal("picked_up")
	queue_free()
