extends Control

@export var local_mode = false

var peer = NodeTunnelPeer.new()
var local_peer = ENetMultiplayerPeer.new()
const PORT: int = 9998
@onready var start_button: Button = $Lobby/PanelContainer/MarginContainer/VBoxContainer/Button
const SERVER_AVAILABLE_CARD = preload("uid://cifyf4rbtvtyc")
#@onready var v_box_container: VBoxContainer = $MainMenu/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer

var player_names : Dictionary

var shown_ips = []

func _ready() -> void:
	if not local_mode:
		multiplayer.multiplayer_peer = peer
		peer.connect_to_relay("relay.nodetunnel.io", PORT)
		await peer.relay_connected
	
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_server():
	if local_mode:
		local_peer.create_server(PORT)
		multiplayer.multiplayer_peer = local_peer
	else:
		peer.host()
		display_ID()
		await peer.hosting
	
	player_names[1] = %NameText.text
	multiplayer.peer_connected.connect(add_player)
	$IPBroadcaster.start_broadcast(%NameText.text + "'s server")
	add_player(multiplayer.get_unique_id())
	$Lobby.show()
	start_button.show()
	$MainMenu.hide()

func create_client(ip, port):
	multiplayer.multiplayer_peer = null
	print("Connecting")
	if local_mode:
		$IPBroadcaster.started = true
		local_peer = ENetMultiplayerPeer.new() 
		var error = local_peer.create_client(ip, port)
		if error != OK:
			print("Failed to initialize client: ", error)
			return
		multiplayer.multiplayer_peer = local_peer
	else:
		peer.join(%IDText.text)
		await peer.joined
	

func _on_connection_success():
	request_name_update.rpc_id(1, %NameText.text)
	$Lobby.show()
	$MainMenu.hide()

func _on_connection_failed():
	pass

func _on_server_disconnected():
	pass

func add_player(id):
	var _name = %NameText.text
	if player_names.find_key(id): _name = player_names[id]
	$Lobby/PanelContainer/MarginContainer/VBoxContainer/ItemList.add_item(_name)
	#print("Peer connected:", id)
	#var l = multiplayer.get_peers()
	#l.append(1)
	#update_lists.rpc(l)

func start_game():
	if not multiplayer.is_server(): return
	start_game_all.rpc()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
	
@rpc("authority")
func start_game_all():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

#@rpc("authority")
#func update_lists(l: Array[int]):
	#$Lobby/PanelContainer/MarginContainer/VBoxContainer/ItemList.clear()
	#for id in l:
		#var _name = player_names[id]
		#if _name:
			#$Lobby/PanelContainer/MarginContainer/VBoxContainer/ItemList.add_item(_name)
		#else:
			#$Lobby/PanelContainer/MarginContainer/VBoxContainer/ItemList.add_item(str(id))

func _on_button_pressed() -> void:
	start_game()

func display_ID() -> void:
	%IDLabel.show()
	%IDLabel.text = peer.online_id

func get_local_IP() -> String:
	for ip in IP.get_local_addresses():
		# Ignore IPv6 and loopback addresses
		if ":" not in ip and ip != "127.0.0.1":
			# On a Windows Hotspot, the host is almost always 192.168.137.1
			# But let's print them all to the console so you can verify!
			print("Found available IP: ", ip)
			if ip.begins_with("192.168.") or ip.begins_with("172.") or ip.begins_with("10."):
				return ip
	return ""

@rpc("any_peer")
func request_name_update(_name: String) -> void:
	var id = multiplayer.get_remote_sender_id()
	player_names[id] = _name
	set_updated_player_names.rpc(player_names)

@rpc("authority", "call_local")
func set_updated_player_names(updated_player_names: Dictionary) -> void:
	player_names = updated_player_names
	var item_list = $Lobby/PanelContainer/MarginContainer/VBoxContainer/ItemList
	item_list.clear()
	for id in updated_player_names:
		item_list.add_item(updated_player_names[id])

func add_available_server(server_ip: String, server_port: int, room_info: Dictionary) -> void:
	if server_ip in shown_ips:
		return
	shown_ips.append(server_ip)
	var card := SERVER_AVAILABLE_CARD.instantiate()
	card.get_node("HBoxContainer/VBoxContainer/Label").text = room_info.name
	card.get_node("HBoxContainer/Button").connect("button_up", create_client.bind(server_ip, server_port))
	%ServerCardParent.add_child(card)
	
