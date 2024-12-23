extends Node

var score = 0
@onready var score_label: Label = $ScoreLabel

func add_point():
	score +=1
	score_label.text = "You collected " + str(score) + " coins."
	
func become_host():
	print("host")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func join_as_player_2():
	print("join as player 2")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_as_player_2()
