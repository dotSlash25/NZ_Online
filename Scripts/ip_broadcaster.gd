extends Node

var broadcaster : PacketPeerUDP
var broadcast_port := 8911
var listen_port := 8912
const PORT: int = 9998
var started = false

var listener := PacketPeerUDP.new()

var room_info := {"name": "", "player_count": 0}

func _ready() -> void:
	var ok = listener.bind(listen_port)
	
	if ok == OK:
		print("Bound to listen port")
	else:
		print("Failed to bind to listen port")
		$ListernerFailed.show()

func _process(_delta: float) -> void:
	if listener.get_available_packet_count() > 0:
		var server_ip = listener.get_packet_ip()
		var server_port = 9998 #listener.get_packet_port()
		var data = listener.get_packet().get_string_from_ascii()
		room_info = JSON.parse_string(data)
		if len(server_ip) < 1: 
			return
		print(server_ip, server_port, room_info)
		get_parent().add_available_server(server_ip, server_port, room_info)
		

func start_broadcast(_name):
	room_info.name = _name
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address("255.255.255.255", listen_port)
	
	var ok = broadcaster.bind(broadcast_port)
	
	if ok == OK:
		print("Bound to broadcast port")
		$Timer.start()
	else:
		print("Failed to broadcast")

func broadcast():
	room_info.player_count = len(get_parent().player_names.keys())
	var data = JSON.stringify(room_info)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func _exit_tree() -> void:
	$Timer.stop()
	listener.close()
	if broadcaster != null:
		broadcaster.close()
