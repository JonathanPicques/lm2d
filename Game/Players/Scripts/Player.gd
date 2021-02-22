extends KinematicBody2D
class_name PlayerNode

###
# Nodes
###

onready var PlayerSprite: Sprite = $Orientation/PlayerSprite
onready var PlayerFlashlight: Light2D = $Orientation/Flashlight
onready var PlayerOrientation: Node2D = $Orientation
onready var PlayerAmbientLight: Light2D = $Orientation/AmbientLight
onready var PlayerAnimationPlayer: AnimationPlayer = $AnimationPlayer
onready var PlayerInteractableArea: Area2D = $CollisionBody/InteractableArea
onready var PlayerFlashlightLightableArea: Area2D = $Orientation/Flashlight/LightableArea

###
# Movement constants
###

const FLOOR := Vector2(0, -1) # floor direction.
const FLOOR_SNAP := Vector2(0, 15) # floor snap for slopes.
const FLOOR_MAX_ANGLE := deg2rad(45) # floor max walkable angle.
const FLOOR_SNAP_DISABLED := Vector2() # no floor snap for slopes.
const FLOOR_SNAP_DISABLE_TIME := 0.1 # time during snapping is disabled.

const JUMP_STRENGTH := -240.0
const CEILING_KNOCKDOWN := 0.0

const RUN_MAX_SPEED := 96.0
const RUN_ACCELERATION := 180.0
const RUN_DECELERATION := 280.0
const RUN_DECELERATION_BRAKE := 1.6

const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

###
# State
###

var state := PlayerStateResource.new()

var velocity := Vector2()
var direction := 1
var disable_snap := 0.0
var input_velocity := Vector2()
var velocity_offset := Vector2()

var flashlight := false
var flashlight_type = Constants.LightType.Normal

onready var fsm := PlayerFiniteStateMachineObject.new(self, $StateMachine, $StateMachine/stand)

###
# Input
###

var input_up := false
var input_down := false
var input_left := false
var input_right := false
var input_jump := false
var input_interact := false
var input_flashlight := false
var input_flashlight_cycle := false

var input_up_once := false
var input_down_once := false
var input_left_once := false
var input_right_once := false
var input_jump_once := false
var input_interact_once := false
var input_flashlight_once := false
var input_flashlight_cycle_once := false

# _ready is called when the player is ready.
# @impure
func _ready():
	set_direction(direction)
	set_flashlight(flashlight)
	set_flashlight_type(flashlight_type)

# _physics_process is called every physics tick and updates player state.
# @impure
func _physics_process(delta: float):
	process_input(delta)
	process_velocity(delta)
	process_flashlight(delta)
	process_interaction(delta)
	fsm.process_state_machine(delta)

# process_input updates player inputs.
# @impure
var _up := false; var _down := false; var _left := false; var _right := false;
var _jump := false; var _interact := false
var _flashlight := false; var _flashlight_cycle := false
func process_input(_delta: float):
	# compute frame input
	input_up = Input.is_action_pressed("player_up")
	input_left = Input.is_action_pressed("player_left")
	input_down = Input.is_action_pressed("player_down")
	input_right = Input.is_action_pressed("player_right")
	input_jump = Input.is_action_pressed("player_jump")
	input_interact = Input.is_action_pressed("player_interact")
	input_flashlight = Input.is_action_pressed("player_flashlight")
	input_flashlight_cycle = Input.is_action_pressed("player_flashlight_cycle")
	# compute repeated input just once (valid the first frame it was pressed)
	input_up_once = not _up and input_up
	input_down_once = not _down and input_down
	input_left_once = not _left and input_left
	input_right_once = not _right and input_right
	input_jump_once = not _jump and input_jump
	input_interact_once = not _interact and input_interact
	input_flashlight_once = not _flashlight and input_flashlight
	input_flashlight_cycle_once = not _flashlight_cycle and input_flashlight_cycle
	# remember we pressed these inputs last frame
	_up = input_up
	_down = input_down
	_left = input_left
	_right = input_right
	_jump = input_jump
	_interact = input_interact
	_flashlight = input_flashlight
	_flashlight_cycle = input_flashlight_cycle
	# compute input velocity
	input_velocity = Vector2(int(input_right) - int(input_left), int(input_down) - int(input_up))

# process_velocity updates player position after applying velocity.
# @impure
func process_velocity(delta: float):
	# decrement snapping time if applicable
	if disable_snap > 0:
		disable_snap = max(disable_snap - delta, 0)
	# save previous velocity
	var velocity_prev := velocity
	# apply movement (and disable snap for jumping)
	velocity = move_and_slide_with_snap(velocity, FLOOR_SNAP if disable_snap == 0 else FLOOR_SNAP_DISABLED, FLOOR, true, 4, FLOOR_MAX_ANGLE)
	# ignore horizontal velocity change
	velocity.x = velocity_prev.x

# process_flashlight updates flashlight type and checks entities to be lit.
# @impure
var lit_entities := []
func process_flashlight(delta: float):
	if flashlight and input_flashlight_cycle_once:
		set_flashlight_type(Constants.LightType.Spectral if flashlight_type == Constants.LightType.Normal else Constants.LightType.Normal)
	if flashlight:
		for node in lit_entities:
			node.lit_pick = false
		for area in PlayerFlashlightLightableArea.get_overlapping_areas():
			var node: Node = area.get_parent()
			if node is EntityNode:
				if not lit_entities.has(node):
					if node.can_be_lit(flashlight_type):
						node.lit_pick = true
						node.on_light_start(flashlight_type)
						lit_entities.push_back(node)
				elif node.can_be_lit(flashlight_type):
						node.lit_pick = true
						node.on_light_process(delta, flashlight_type)
		for node in lit_entities:
			if not node.lit_pick:
				node.on_light_finish(flashlight_type)
				lit_entities.erase(node)

# process_interaction checks interactable entities.
# @impure
func process_interaction(_delta: float):
	var areas = PlayerInteractableArea.get_overlapping_areas()
	for area in areas:
		var node: Node = area.get_parent()
		if node is EntityNode:
			if input_interact_once and node.can_interact():
				node.on_interact()

###
# Player gameplay
###

# set_flashlight hides or shows the flashlight cone.
# @impure
func set_flashlight(new_flashlight: bool):
	flashlight = new_flashlight
	PlayerFlashlight.enabled = new_flashlight
	PlayerAmbientLight.enabled = new_flashlight
	PlayerFlashlightLightableArea.monitoring = new_flashlight

# set_flashlight changes the type of the flashlight (light or spectral light).
# @param new_flashlight_type - Constants.LightType
# @impure
func set_flashlight_type(new_flashlight_type: int):
	flashlight_type = new_flashlight_type
	match flashlight_type:
		Constants.LightType.Normal:
			PlayerFlashlight.color = Color.white
			PlayerFlashlight.range_item_cull_mask = Constants.LightType.Normal
			PlayerFlashlight.shadow_item_cull_mask = Constants.LightType.Normal
			PlayerAmbientLight.color = Color.white
			PlayerAmbientLight.range_item_cull_mask = Constants.LightType.Normal
			PlayerAmbientLight.shadow_item_cull_mask = Constants.LightType.Normal
		Constants.LightType.Spectral:
			PlayerFlashlight.color = Color.cornflower
			PlayerFlashlight.range_item_cull_mask = Constants.LightType.Spectral
			PlayerFlashlight.shadow_item_cull_mask = Constants.LightType.Spectral
			PlayerAmbientLight.color = Color.white
			PlayerAmbientLight.range_item_cull_mask = Constants.LightType.Spectral
			PlayerAmbientLight.shadow_item_cull_mask = Constants.LightType.Spectral

###
# Player helpers
###

# set_direction changes the player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: int):
	direction = new_direction
	PlayerOrientation.scale.x = abs(PlayerOrientation.scale.x) * sign(direction)

# set_animation changes the player animation to the given animation name.
# @impure
func set_animation(animation_name: String):
	var anim_name := animation_name
	var anim_name_flashlight := "%s_flashlight" % animation_name
	var current_anim_position := PlayerAnimationPlayer.current_animation_position
	# try to keep animation time (walk -> walk_flashlight)
	var anim_playing := is_animation_playing(anim_name)
	var anim_flashlight_playing := is_animation_playing(anim_name_flashlight)
	if flashlight:
		PlayerAnimationPlayer.play(anim_name_flashlight)
		if anim_playing:
			PlayerAnimationPlayer.seek(current_anim_position, true)
	else:
		PlayerAnimationPlayer.play(anim_name)
		if anim_flashlight_playing:
			PlayerAnimationPlayer.seek(current_anim_position, true)

# is_animation_playing returns true if the given animation is playing.
# @impure
func is_animation_playing(animation: String) -> bool:
	return PlayerAnimationPlayer.current_animation == animation

# is_animation_finished returns true if the animation is finished (and not looping).
# @pure
func is_animation_finished() -> bool:
	return not PlayerAnimationPlayer.is_playing()

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
	velocity.y = move_toward(velocity.y, max_speed, delta * acceleration)

# handle_direction changes the direction depending on the input velocity.
# @impure
func handle_direction():
	var input_direction := int(sign(input_velocity.x))
	if input_direction != 0:
		set_direction(input_direction)

# handle_floor_move applies acceleration or deceleration depending on the input_velocity on the floor.
# @impure
func handle_floor_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if velocity.x == 0 or has_same_direction(velocity.x, input_velocity.x):
		velocity.x = get_acceleration(delta, velocity.x, max_speed, acceleration)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_airborne_move applies acceleration or deceleration depending on the input_velocity while airborne.
# @impure
func handle_airborne_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if velocity.x == 0 or has_same_direction(velocity.x, input_velocity.x):
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

###
# Player effects
###

# @impure
func play_fx_land():
	$Sounds/StepSoundPlayer.play()

# @impure
func play_fx_step():
	$Sounds/StepSoundPlayer.play()

# @impure
func play_fx_jump():
	$Sounds/JumpSoundPlayer.play()

# @impure
func play_fx_floor_turn():
	$Sounds/FloorTurnSoundPlayer.play()

# @impure
func play_fx_bump_ceiling():
	pass

# @impure
func play_fx_toggle_flashlight():
	$Sounds/FlashlightToggleSoundPlayer.play()
