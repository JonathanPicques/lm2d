extends EntityNode

# @impure
func _ready():
	$RigidBody2D.apply_impulse(Vector2(0.0, -2.0), Vector2((-1.0 if randf() < 0.5 else 1.0) * rand_range(13.0, 22.0), -120.0))

# @impure
func on_body_entered(_body: Node):
	if $RigidBody2D.linear_velocity.length() > Constants.PhysicsSleepLength:
		$RigidBody2D/AudioStreamPlayer2D.play()
