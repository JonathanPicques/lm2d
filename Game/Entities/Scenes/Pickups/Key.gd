extends EntityNode

func _ready():
	$RigidBody2D.apply_impulse(Vector2(0.0, -2.0), Vector2(-1.0 if randf() < 0.5 else 1.0 * rand_range(15.0, 28.0), -120.0))
