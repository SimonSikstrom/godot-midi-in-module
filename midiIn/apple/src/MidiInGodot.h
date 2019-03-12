#ifndef GODOT_MidiInGodot_H
#define GODOT_MidiInGodot_H

#include <core/reference.h>

#include "MidiInCppListener.h"

#ifdef __OBJC__
@class MidiInHandler;
#else
typedef void MidiInHandler;
#endif

class MidiInGodot : public Reference, public MidiInCppListener {
private:
    GDCLASS(MidiInGodot, Reference);
    MidiInHandler *handler;
    ObjectID instanceId;

    void release_handler();

protected:
    static void _bind_methods();

public:
    MidiInGodot();
    ~MidiInGodot();
    void init(ObjectID instance_id);
    void _device_added(int32_t id, std::string name);
    void _device_removed(int32_t id);
    void _device_connected_on_port(int32_t id, int32_t port);
    void _device_packet_received_on_port(int32_t id, int32_t port, int64_t time, std::vector<uint8_t> data);
    void _midi_not_available();
};

#endif /* GODOT_MidiInGodot_H */