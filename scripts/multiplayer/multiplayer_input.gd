extends MultiplayerSynchronizer

var input_direction
@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#multiplayer.get_unique_id() a le network id local
	#si c'est différent ça veut dire que le client n'est pas local
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	#get the input direction: -1, 0, 1
	input_direction = Input.get_axis("move_left", "move_right")

func _physics_process(delta: float) -> void:
	#get the input direction: -1, 0, 1
	input_direction = Input.get_axis("move_left", "move_right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		#call a rpc / appeler une fonction rpc
		jump.rpc()

#remote procedure call : allow to send msgs to client and server respectively
@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true
