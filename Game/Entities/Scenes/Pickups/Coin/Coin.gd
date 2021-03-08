extends EntityPickupNode
class_name CoinEntityPickupNode

onready var CoinArea2D: Area2D = $Area2D
onready var CoinRigidBody2D: RigidBody2D = $RigidBody2D
onready var CoinAnimatedSprite: AnimatedSprite = $RigidBody2D/AnimatedSprite
onready var CoinAudioStreamPlayer2D: AudioStreamPlayer2D = $RigidBody2D/AudioStreamPlayer2D

###
# Process
###

# @impure
func _ready():
	CoinArea2D.set_deferred("monitorable", false)

# @impure
func _process(_delta: float):
	CoinArea2D.position = CoinRigidBody2D.position

# @impure
func on_body_entered(_body: Node):
	if CoinRigidBody2D.linear_velocity.length() > Constants.PhysicsSleepLength:
		CoinAudioStreamPlayer2D.play()
	else:
		CoinArea2D.set_deferred("monitorable", true)

###
# Pickup
###

# @override
func can_be_picked_up() -> bool:
	return true

# @override
func on_pickup():
	emit_signal("picked_up")
	queue_free()
