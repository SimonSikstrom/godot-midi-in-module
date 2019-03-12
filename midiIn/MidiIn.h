
#ifndef GODOT_MIDIIN_H
#define GODOT_MIDIIN_H

#include <core/reference.h>
#include <scene/main/node.h>

class MidiIn : public Node {
private:
    GDCLASS(MidiIn, Node);

protected:
    static void _bind_methods();
    
    void _ready_native();

    void _midi_not_available_native();
    void _device_added_native(int id, const String &name);
    void _device_removed_native(int id);
    void _device_connected_on_port_native(int id, int port);
    void _device_packet_received_on_port_native(int id, int port, const Variant time, const PoolByteArray & bytes);

public:
    MidiIn();
};

#endif /* GODOT_MIDIIN_H */