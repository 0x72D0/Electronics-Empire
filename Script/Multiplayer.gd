extends Control

var globals
var gameScene

func _ready():
	self.globals = get_node("/root/globals")
	self.gameScene = load("res://Scene/Game.tscn").instance()
	pass
	
func __create_button__():
	get_tree().get_root().add_child(gameScene)
	self.get_node("Connection").hide()
	
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(globals.GAME_PORT, globals.MAX_PLAYERS)
	if(err != OK):
		#is another server running?
		return
	
	get_tree().set_network_peer(peer)
	self.gameScene.generate_world()
	pass
	
func __connect_button__():
	get_tree().get_root().add_child(gameScene)
	var ip = get_node("Connection/VBoxContainer/HBoxContainer2/IpAdressLineEdit").get_text()
	if not ip.is_valid_ip_address():
		return
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, globals.GAME_PORT)
	get_tree().set_network_peer(host)
	self.get_node("Connection").hide()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
