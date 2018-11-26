# CURRENTLY ONLY WORKS WITH GODOT VERSION >=3.1

# A [GODOT Engine](https://github.com/godotengine/godot) MIDI In Module for Android & iOS
## (+ MacOS for testing)

This GODOT module is primarliy for iOS and Android devices to make it easier to listen on midi in signals from your smartphone.

For every midi device you connect to the device you will get the callbacks you need to read the midi device data on a specific port.

### TODO
* Test on iOS
* Android Bluetooth support?
* Proper README.md

## Example project

    ./example


## How to

Compile Godot with ```./midiIn``` in the godot ```module``` dir.

Read up on how to compile for Android here http://docs.godotengine.org/en/3.0/development/compiling/compiling_for_android.html


In your project add this to your ```project.godot```

    [android]
    modules="org/godotengine/godot/GodotMidiIn"


## Example gdscript
```
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

# If the current platform does not support midi
func _midi_not_available():
	print("_midi_not_available")

# if a new midi device is added
func _device_added(id, name):
	print("_device_added ", id, " ", name)

# If the midi device has been connected to a port
func _device_connected_on_port(id, port):
	print("_device_connected_on_port ", id, " ", port)

# If the midi device disconnected
func _device_removed(id):
	print("_device_removed ", id)

# All packets from the midi device. 
# Note for Android: See https://developer.android.com/reference/android/media/midi/package-summary
# The data that arrives is not validated or aligned in any particular way. It is raw MIDI data and
# can contain multiple messages or partial messages. It might contain System Real-Time messages,
# which can be interleaved inside other messages.

func _device_packet_received_on_port(id, port, timestamp, packet):
	
	# Create mutable packet
	var mPacket = Array(packet)
	
	# First byte is a status byte.
	# https://users.cs.cf.ac.uk/Dave.Marshall/Multimedia/node158.html
	var status = mPacket.pop_front()
	# Here is a simple example how to separate the packets, only tested with regular piano keys
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

```
