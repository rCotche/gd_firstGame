extends MultiplayerSynchronizer

var input_direction

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
	pass
