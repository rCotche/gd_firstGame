extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction = 1

@export var player_id := 1:
	set(id):
		player_id = id
		#establish client authority
		%InputSynchronizer.set_multiplayer_authority(id)

func _apply_animations(delta):
	#Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	#Play animation
	if is_on_floor():
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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#get the input direction: -1, 0, 1
	var direction = %InputSynchronizer.input_direction
	
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
		_apply_movement_from_input(delta)
