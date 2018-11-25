#include "midiIn.h"

#ifdef __OBJC__
#import "MidiInHandler.h"
#endif

MidiIn::MidiIn(): instanceId(0) {
    printf("MidiIn Module instance created\n");
}

MidiIn::~MidiIn() {
    if (instanceId) {
        [handler release];
        printf("MidiIn Module handler released\n");
    }
    printf("MidiIn Module instance released\n");
}

void MidiIn::_device_added(int32_t id, std::string name) {
    ObjectDB::get_instance(instanceId)->call_deferred("_device_added", id, name.c_str());
}
void MidiIn::_device_removed(int32_t id) {
    ObjectDB::get_instance(instanceId)->call_deferred("_device_removed", id);
}
void MidiIn::_device_connected_on_port(int32_t id, int32_t port) {
    ObjectDB::get_instance(instanceId)->call_deferred("_device_connected_on_port", id, port);
}
void MidiIn::_device_packet_received_on_port(int32_t id, int32_t port, int64_t time, std::vector<uint8_t> data) {
    PoolByteArray pba;
    pba.resize(data.size());
    PoolByteArray::Write w = pba.write();
    for (int i = 0; i < data.size(); i++) w[i] = data[i];
    ObjectDB::get_instance(instanceId)->call_deferred("_device_packet_received_on_port", id, port, time, pba);
}
void MidiIn::_midi_not_available() {
    ObjectDB::get_instance(instanceId)->call_deferred("_midi_not_available");
}

void MidiIn::init(ObjectID instance_id) {
    const bool first_init = !instanceId;
    instanceId = instance_id;
#ifdef __OBJC__
    if (first_init) {
        handler = [[MidiInHandler alloc] initWithListener: this];
    }
#endif
}

void MidiIn::_bind_methods() {
    ClassDB::bind_method(D_METHOD("init", "instance_id"), &MidiIn::init);
}
