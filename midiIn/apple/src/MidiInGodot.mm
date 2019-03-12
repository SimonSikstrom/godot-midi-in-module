#include "MidiInGodot.h"

#import "MidiInHandler.h"

MidiInGodot::MidiInGodot(): instanceId(0) {}

MidiInGodot::~MidiInGodot() {
    release_handler();
}

void MidiInGodot::_device_added(int32_t id, std::string name) {
    ObjectDB::get_instance(instanceId)->call_deferred("_device_added_native", id, name.c_str());
}
void MidiInGodot::_device_removed(int32_t id) {
    ObjectDB::get_instance(instanceId)->call_deferred("_device_removed_native", id);
}
void MidiInGodot::_device_connected_on_port(int32_t id, int32_t port) {
    ObjectDB::get_instance(instanceId)->call_deferred("_device_connected_on_port_native", id, port);
}
void MidiInGodot::_device_packet_received_on_port(int32_t id, int32_t port, int64_t time, std::vector<uint8_t> data) {
    PoolByteArray pba;
    pba.resize(data.size());
    PoolByteArray::Write w = pba.write();
    for (int i = 0; i < data.size(); i++) w[i] = data[i];
    ObjectDB::get_instance(instanceId)->call_deferred("_device_packet_received_on_port_native", id, port, time, pba);
}
void MidiInGodot::_midi_not_available() {
    ObjectDB::get_instance(instanceId)->call_deferred("_midi_not_available_native");
}

void MidiInGodot::release_handler() {
    if (handler) {
        [handler release];
        handler = nil;
    }
}

void MidiInGodot::init(ObjectID instance_id) {
    release_handler();
    instanceId = instance_id;
    handler = [[MidiInHandler alloc] initWithListener: this];
}

void MidiInGodot::_bind_methods() {
    ClassDB::bind_method(D_METHOD("init", "instance_id"), &MidiInGodot::init);
}
