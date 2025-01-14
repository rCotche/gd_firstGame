extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if not MultiplayerManager.multiplayer_mode_enabled:
		print("you died!")
		#slow the time in our game
		Engine.time_scale = 0.5
		#body fait reference à notre player
		#car il y a que le player qui collision avec
		#queue_free() = remove le node
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	else:
		_multiplayer_dead(body)

func _multiplayer_dead(body):
	if multiplayer.is_server():
		Engine.time_scale = 0.5
		body.mark_dead()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	#restart our game
	get_tree().reload_current_scene()
