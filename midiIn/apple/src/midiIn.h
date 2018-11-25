#ifndef GODOT_MIDIIN_H
#define GODOT_MIDIIN_H

#include <core/reference.h>

#include "MidiInCppListener.h"

#ifdef __OBJC__
@class MidiInHandler;
#else
typedef void MidiInHandler;
#endif

class MidiIn : public Reference, public MidiInCppListener {
private:
    GDCLASS(MidiIn, Reference);
    MidiInHandler *handler;
    ObjectID instanceId;

protected:
    static void _bind_methods();

public:
    MidiIn();
    ~MidiIn();
    void init(ObjectID instance_id);
    void _device_added(int32_t id, std::string name);
    void _device_removed(int32_t id);
    void _device_connected_on_port(int32_t id, int32_t port);
    void _device_packet_received_on_port(int32_t id, int32_t port, int64_t time, std::vector<uint8_t> data);
    void _midi_not_available();
};

#endif /* GODOT_MIDIIN_H */