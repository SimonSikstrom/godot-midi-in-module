#ifndef MidiInCppListener_h
#define MidiInCppListener_h

#include <string>
#include <vector>

class MidiInCppListener {
public:
    virtual void _device_added(int32_t id, std::string name) = 0;
    virtual void _device_removed(int32_t id) = 0;
    virtual void _device_connected_on_port(int32_t id, int32_t port) = 0;
    virtual void _device_packet_received_on_port(int32_t id, int32_t port, int64_t time, std::vector<uint8_t> data) = 0;
    virtual void _midi_not_available() = 0;
};

#endif /* MidiInCppListener_h */
