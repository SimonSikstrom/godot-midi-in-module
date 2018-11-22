extends Node

var midi = null

signal midi_key_down(key, velocity)
signal midi_key_up(key)

func _ready():
	if(Engine.has_singleton("MidiIn")):
		midi = Engine.get_singleton("MidiIn")
		midi.init(get_instance_id())
		if midi == null:
			_midi_not_available()
	else:
		_midi_not_available()

func _midi_not_available():
	print("_midi_not_available")

func _device_added(id, name):
	print("_device_added ", id, " ", name)

func _device_connected_on_port(id, port):
	print("_device_connected_on_port ", id, " ", port)

func _device_removed(id):
	print("_device_removed ", id)

func _device_packet_received_on_port(id, port, timestamp, packet):
	
	# Create mutable packet
	var mPacket = Array(packet)
	
	# Firs byte is status byte.
	# https://users.cs.cf.ac.uk/Dave.Marshall/Multimedia/node158.html
	var status = mPacket.pop_front()
	while status:
		if status & 0xF0 == 0xF0:
			# Ignore all system messages
			status = mPacket.pop_front()
			continue
		
		# Extract the data bytes
		var dataByte1 = mPacket.pop_front()
		var dataByte2 = mPacket.pop_front()
		
		match status & 0xF0:
			0x80: # Note off
				var key = dataByte1
				var velocity = dataByte2
				emit_signal("midi_key_up", key)
			0x90: # Note on
				var key = dataByte1
				var velocity = dataByte2
				if velocity > 0:
					emit_signal("midi_key_down", key, velocity)
				else: # also release indicator if velocity is zero on some devices
					emit_signal("midi_key_up", key)	
		
		status = mPacket.pop_front()
