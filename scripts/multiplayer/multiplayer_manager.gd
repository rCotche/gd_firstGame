extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

#declare scene
var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")

#declare reference
var _player_spawn_node
var host_mode_enabled = false
var multiplayer_mode_enabled = false
var respawn_point = Vector2(30,20)

func become_host():
	print("starting host!")
	
	#equivalent de $Players ?
	#le script est un autoload donc n'est pas attaché à un node
	#dont refresh scene when the player died en multiplayer mode
	_player_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	host_mode_enabled = true
	multiplayer_mode_enabled = true
	
	#ENetMultiplayerPeer : C'est un outil de Godot
	#qui utilise ENet pour permettre
	#à plusieurs joueurs de se connecter les uns aux autres.
	#Il gère les connexions, l'envoi et la réception de données.
	
	#Un "peer" dans ce contexte représente une entité
	#capable de se connecter au réseau,
	#soit comme serveur (celui qui héberge le jeu),
	#soit comme client (ceux qui se connectent au serveur).
	#
	#Ici, on crée un peer serveur,
	#ce qui signifie qu'on veut que le jeu devienne le hôte du multijoueur.
	#Tous les autres joueurs vont se connecter à cette instance.
	var server_peer = ENetMultiplayerPeer.new()#step 1 to create server: instance
	#La méthode create_server(SERVER_PORT)
	#configure le server_peer
	#pour qu'il écoute les connexions
	#sur un port spécifique.
	server_peer.create_server(SERVER_PORT)#step 2 to create server: configure it
	
	#multiplayer est une propriété intégrée dans Godot
	#qui appartient à tous les nœuds.
	#C'est l'outil principal utilisé pour gérer le multijoueur dans ton jeu.
	#En résumé, multiplayer coordonne toutes les fonctionnalités multijoueur
	#il sait si tu es un serveur, un client,
	#et il gère l'envoi et la réception des messages entre les joueurs.
	
	#Tu dis à Godot :"Mon système multijoueur (multiplayer)
	#va utiliser l'objet server_peer
	#que j'ai configuré comme serveur.
	#Cela signifie que ton jeu devient un serveur multijoueur
	#et est maintenant prêt à accepter les connexions d'autres joueurs.
	multiplayer.multiplayer_peer = server_peer#step 3 to create server: use it
	
	#signal
	#quand un joueur se connecte
	multiplayer.peer_connected.connect(_add_player_to_game)
	#signal
	#quand un joueur se deconnecte
	multiplayer.peer_disconnected.connect(_del_player)
	
	_remove_single_player()
	
	#serveur ou host a toujours un "network id" 1
	_add_player_to_game(1)
func join_as_player_2():
	print("joined !")
	multiplayer_mode_enabled = true
	
	#step 1 to create client: instance
	var client_peer = ENetMultiplayerPeer.new()
	#step 2 to create client: configure it
	client_peer.create_client(SERVER_IP,SERVER_PORT)
	#step 3 to create client: use it
	multiplayer.multiplayer_peer = client_peer
	
	_remove_single_player()
	

func _add_player_to_game(id: int):
	#Affiche un message en remplaçant %s par la valeur de id.
	print("Player %s joined" % id)
	
	#instantiate the scene
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	#add a child dasn le noeud Players
	#the multiplayer spawner gonna detect that
	#car on a demande au MultiplayerSpawner de regarder multiplayer_scene
	#Maintenant le MultiplayerSpawner va spawn et sync the multiplayer player
	_player_spawn_node.add_child(player_to_add, true)
	
func _del_player(id: int):
	#Affiche un message en remplaçant %s par la valeur de id.
	print("Player %s left" % id)
	#si il y a pas de player avec l'id alors ne fait rien
	if not _player_spawn_node.has_node(str(id)):
		return
	
	#delete le player avec l'id
	_player_spawn_node.get_node(str(id)).queue_free()

func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
