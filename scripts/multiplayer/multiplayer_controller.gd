extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction = 1
var do_jump = false
var _is_on_floor = true

@export var player_id := 1:
	set(id):
		player_id = id
		#establish client authority
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready() -> void:
	#make camera run only on client
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func _apply_animations(delta):
	#Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	#Play animation
	if _is_on_floor:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
func _apply_movement_from_input(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if do_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		do_jump = false

	#get the input direction: -1, 0, 1
	direction = %InputSynchronizer.input_direction
	
	#apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _physics_process(delta: float) -> void:
	#on souhaite que seul le serveur peut appliquer des changements
	
	#check si c'est le serveur
	#si oui alors apply movement
	if multiplayer.is_server():
		_is_on_floor = is_on_floor()
		_apply_movement_from_input(delta)
	
	#MultiplayerManager : autoload
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)
		

func mark_dead():
	print("mark player died")
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func _respawn():
	print("Respawned")
	$CollisionShape2D.set_deferred("disabled", false)
	position = MultiplayerManager.respawn_point
	#$CollisionShape2D.set_deferred("disabled", false)
