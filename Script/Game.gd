extends Node

var execute_button
var world
var globals
var alert_dialog
var network_info

# generate all the objects, empty for now
func __generate_object__():
	pass

# generate the client player
sync func generate_player(id):
	var player = load("res://Script/player.gd").new()
	add_child(player)
	var random_x_location
	var random_y_location
	var init_pos
	
	random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
	random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
	init_pos = Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2)
	
	while(self.world.get_cell((init_pos.x/self.globals.tileSize.x), (init_pos.y/self.globals.tileSize.y)) == self.world.water
		  || self.world.get_cell((init_pos.x/self.globals.tileSize.x), (init_pos.y/self.globals.tileSize.y)) == self.world.border):
		random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
		random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
		init_pos = Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2)
	
	player.generate_lg401(init_pos)
	player.set_name(str(id))
	self.network_info.player_list.append(str(id))
	pass

remote func ask_sync_player():
	for player in self.network_info.player_list:
		rpc("sync_player", player)
	rpc("continue_all")
	pass

remote func sync_player(player):
	if(!has_node(player)):
		var new_player = load("res://Script/player.gd").new()
		new_player.set_name(player)
		add_child(new_player)
		new_player.rpc_id(1,"ask_player_sync")
	pass

# pause all the player
sync func pause_all():
	self.alert_dialog.show_dialog("the game is synchronizing with the new player")
	get_tree().set_pause(true)
	pass

# the synchronization is complete, resume all the player
sync func continue_all():
	get_tree().set_pause(false)
	self.alert_dialog.close_dialog()
	pass

# call in Multiplayer.gd, generate the world
func generate_world():
	self.world.__generate_world__()
	pass

# signal in WorldGen.gd, when the world generation is finish we generate all
# the remaining components
func generation_finished():
	randomize()
	generate_player(get_tree().get_network_unique_id())
	__generate_object__()
	pass

# send a line when we click on the execute button
func execute_button(text):
	self.get_node(str(get_tree().get_network_unique_id())).rpc("send_line",text)
	pass

# function is call on the server and client when a new peer is connected
func new_peer(id):
	print("network working!")
	pass

# function is call on the server and client when a peer disconnected
func peer_left(id):
	pass

# function is call on the client when a new peer is connected
func player_connection():
	rpc("pause_all")
	rpc_id(1, "generate_player", get_tree().get_network_unique_id())
	self.world.rpc_id(1,"__ask_sync_world__")
	rpc_id(1,"ask_sync_player")
	pass

# function is call on the client when a peer failed to connect
func player_connection_failed():
	pass

# function is call on the client when the server disconnect
func server_disconnected():
	pass

func _ready():
	
	self.execute_button = get_node("Camera2D/GUI/GUI_execute_button")
	self.world = get_node("World")
	self.globals = get_node("/root/globals")
	self.network_info = get_node("/root/network_info")
	self.alert_dialog = get_node("Camera2D/GUI/AlertDialog")
	
	self.execute_button.connect("button_pressed_signal", self, "execute_button")
	self.world.connect("Generation_finished_signal", self, "generation_finished")
	get_tree().connect("network_peer_connected", self, "new_peer")
	get_tree().connect("network_peer_disconnected", self, "peer_left")
	get_tree().connect("connected_to_server", self, "player_connection")
	get_tree().connect("connection_failed", self, "player_connection_failed")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	
	pass