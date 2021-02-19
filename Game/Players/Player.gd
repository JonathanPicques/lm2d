extends KinematicBody2D
class_name PlayerNode

const FLOOR := Vector2(0, -1) # floor direction.
const FLOOR_SNAP := Vector2(0, 5) # floor snap for slopes.
const FLOOR_SNAP_DISABLED := Vector2() # no floor snap for slopes.
const FLOOR_SNAP_DISABLE_TIME := 0.1 # time during snapping is disabled.
const FALLING_VELOCITY_THRESHOLD := 5.0 # velocity were we consider the player is falling

const JUMP_STRENGTH := -240.0
const CEILING_KNOCKDOWN := 0.0

const RUN_MAX_SPEED := 96.0
const RUN_ACCELERATION := 200.0
const RUN_DECELERATION := 390.0

const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

var velocity := Vector2()
var direction := 1
var disable_snap := 0.0
var velocity_prev := Vector2()
var input_velocity := Vector2()
var velocity_offset := Vector2()

var flashlight := false

var input_up := false
var input_down := false
var input_left := false
var input_right := false
var input_jump := false
var input_flashlight := false
var input_up_once := false
var input_down_once := false
var input_left_once := false
var input_right_once := false
var input_jump_once := false
var input_flashlight_once := false

onready var PlayerSprite: Sprite = $Orientation/PlayerSpriteSprite
onready var PlayerFlashlight: Light2D = $Orientation/Flashlight
onready var PlayerOrientation: Node2D = $Orientation
onready var PlayerAnimationPlayer: AnimationPlayer = $AnimationPlayer

onready var fsm := PlayerFiniteStateMachineObject.new(self, $StateMachine, $StateMachine/stand)

# _ready is called when the player is ready.
# @impure
func _ready():
	set_direction(direction)
	set_flashlight(flashlight)

# _physics_process is called every physics tick and updates player state.
# @impure
func _physics_process(delta: float):
	process_input(delta)
	process_velocity(delta)
	fsm.process_state_machine(delta)
	# debug
	$Label.text = fsm.current_state_node.name

# process_input updates player inputs.
# @impure
var _up := false; var _down := false; var _left := false; var _right := false;
var _jump := false; var _flashlight := false
func process_input(delta: float):
	# compute frame input
	input_up = Input.is_action_pressed("player_up")
	input_left = Input.is_action_pressed("player_left")
	input_down = Input.is_action_pressed("player_down")
	input_right = Input.is_action_pressed("player_right")
	input_jump = Input.is_action_pressed("player_jump")
	input_flashlight = Input.is_action_pressed("player_flashlight")
	# compute repeated input just once (valid the first frame it was pressed)
	input_up_once = not _up and input_up
	input_down_once = not _down and input_down
	input_left_once = not _left and input_left
	input_right_once = not _right and input_right
	input_jump_once = not _jump and input_jump
	input_flashlight_once = not _flashlight and input_flashlight
	# remember we pressed these inputs last frame
	_up = input_up
	_down = input_down
	_left = input_left
	_right = input_right
	_jump = input_jump
	_flashlight = input_flashlight
	# compute input velocity
	input_velocity = Vector2(int(input_right) - int(input_left), int(input_down) - int(input_up))

# process_velocity updates player position after applying velocity.
# @impure
var _was_on_floor := false
func process_velocity(delta: float):
	# decrement snapping time if applicable
	if disable_snap > 0:
		disable_snap = max(disable_snap - delta, 0)
	# save old position
	var old_position := position
	# stop movement to avoid sloppy stutters in kinematic body
	if not _was_on_floor and is_on_floor():
		for i in get_slide_count():
			var collision := get_slide_collision(i)
			if is_nearly(velocity_prev.x, 0) and is_nearly(input_velocity.x, 0) and collision.normal != FLOOR:
				velocity = Vector2()
	# save last frame floor status
	_was_on_floor = is_on_floor()
	# save last frame velocity
	velocity_prev = velocity
	# apply movement (and disable snap for jumping)
	velocity = move_and_slide_with_snap(velocity, FLOOR_SNAP if disable_snap == 0 else FLOOR_SNAP_DISABLED, FLOOR, true)
	# compute real velocity offset without taking too small values into account
	var offset := position - old_position
	velocity_offset = Vector2(
		0.0 if is_nearly(offset.x, 0) else velocity.x,
		0.0 if is_nearly(offset.y, 0) else velocity.y
	)

###
# Player helpers
###

# set_direction changes the Player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: int):
	direction = new_direction
	PlayerOrientation.scale.x = abs(PlayerOrientation.scale.x) * sign(direction)

# set_animation changes the Player animation.
# @impure
func set_animation(new_animation: String, play_from_frame := -1):
	var animation_name := new_animation if not flashlight else "%s_flashlight" % new_animation
	
	if not is_animation_playing(animation_name):
		PlayerAnimationPlayer.play(animation_name)
	if play_from_frame != -1:
		var animation := PlayerAnimationPlayer.get_animation(PlayerAnimationPlayer.current_animation)
		var track_time := animation.track_get_key_time(animation.find_track("Sprite:frame"), play_from_frame)
		PlayerAnimationPlayer.play(animation_name)
		PlayerAnimationPlayer.seek(track_time, true)

# is_animation_playing returns true if the given animation is playing.
# @impure
func is_animation_playing(animation: String) -> bool:
	return PlayerAnimationPlayer.current_animation == animation

# is_animation_finished returns true if the animation is finished (and not looping).
# @pure
func is_animation_finished() -> bool:
	return not PlayerAnimationPlayer.is_playing()

# set_flashlight hides or shows the flashlight cone.
# @impure
func set_flashlight(new_flashlight: bool):
	flashlight = new_flashlight
	PlayerFlashlight.enabled = new_flashlight

###
# Movement helpers
###

# handle_jump applies strength to jump and disable floor snapping for a little while.
# @impure
func handle_jump(strength: float):
	velocity.y = strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_gravity applies gravity to the velocity.
# @impure
func handle_gravity(delta: float, max_speed: float, acceleration: float):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_speed, delta * acceleration)
	elif velocity.x == 0 and input_velocity.x == 0:
		velocity.y = 0

# handle_direction changes the direction depending on the input velocity.
# @impure
func handle_direction():
	var input_direction := int(sign(input_velocity.x))
	if input_direction != 0:
		set_direction(input_direction)

# handle_floor_move applies acceleration or deceleration depending on the input_velocity on the floor.
# @impure
func handle_floor_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if has_same_direction(direction, input_velocity.x):
		velocity.x = get_acceleration(delta, velocity.x, max_speed, acceleration)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_airborne_move applies acceleration or deceleration depending on the input_velocity while airborne.
# @impure
func handle_airborne_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if input_velocity.x != 0:
		velocity.x = get_acceleration(delta, velocity.x, max_speed, acceleration, input_velocity.x)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_deceleration_move applies deceleration.
# @impure
func handle_deceleration_move(delta: float, deceleration: float):
	velocity.x = get_deceleration(delta, velocity.x, deceleration)

###
# Movement checkers
###

# is_able_to_jump returns true if the player is able to jump.
# @pure
func is_able_to_jump() -> bool:
	return true

# is_on_wall_passive returns true if there is a wall on the side.
# @pure
func is_on_wall_passive() -> bool:
	return test_move(transform, Vector2(direction, 0))

# is_on_ceiling_passive returns true if there is a ceiling upward.
# @pure
func is_on_ceiling_passive() -> bool:
	# if PlayerCeilingChecker.is_colliding():
	#	var collider := PlayerCeilingChecker.get_collider()
	#	if collider is KinematicBody2D:
	#		# TODO: return true only if collider is not a one-way platform
	#		return false
	#	return false
	return false

###
# Maths helpers
###

# is_nearly returns true if the first given value nearly equals the second given value.
# @pure
func is_nearly(value1: float, value2: float, epsilon = 0.001) -> bool:
	return abs(value1 - value2) < epsilon

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @pure
func has_same_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) == sign(dir2)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @pure
func has_invert_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) != sign(dir2)

# get_acceleration returns the next value after acceleration is applied.
# @pure
func get_acceleration(delta: float, value: float, max_speed: float, acceleration: float, override_direction = direction) -> float:
	return move_toward(value, max_speed * sign(override_direction), acceleration * delta)

# get_deceleration returns the next value after deceleration is applied.
# @pure
func get_deceleration(delta: float, value: float, deceleration: float) -> float:
	return move_toward(value, 0.0, deceleration * delta)
