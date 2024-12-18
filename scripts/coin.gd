extends Area2D



func _on_body_entered(body: Node2D) -> void:
	print("+1 coin")
	#simply remove the entire coin scene from our game
	queue_free()
