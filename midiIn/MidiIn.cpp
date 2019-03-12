#include "MidiIn.h"

#include <core/engine.h>

#if defined(IPHONE_ENABLED) || defined(OSX_ENABLED)
#include "apple/src/MidiInGodot.h"
#endif

MidiIn::MidiIn() {
    connect("ready", this, "_ready_native");
}

void MidiIn::_midi_not_available_native() {
    emit_signal("_midi_not_available");
}

void MidiIn::_device_added_native(int id, const String &name) {
    emit_signal("_device_added", id, name);
}

void MidiIn::_device_removed_native(int id) {
    emit_signal("_device_removed", id);
}

void MidiIn::_device_connected_on_port_native(int id, int port) {
    emit_signal("_device_connected_on_port", id, port);
}

void MidiIn::_device_packet_received_on_port_native(int id, int port, const Variant time, const PoolByteArray & packet) {
    emit_signal("_device_packet_received_on_port", id, port, time, packet);
}

void MidiIn::_ready_native() {
    if (Engine::get_singleton()->has_singleton("MidiInGodot")) {
        Object * midi = Engine::get_singleton()->get_singleton_object("MidiInGodot");
        if (!midi) {
            _midi_not_available_native();
        }
        else {
            midi->call_deferred("init", get_instance_id());
        }
    }
    else {
        _midi_not_available_native();
    }
}

void MidiIn::_bind_methods() {
    ADD_SIGNAL(MethodInfo("_midi_not_available"));
    ADD_SIGNAL(MethodInfo("_device_added", PropertyInfo(Variant::INT, "id"), PropertyInfo(Variant::STRING, "name")));
    ADD_SIGNAL(MethodInfo("_device_removed", PropertyInfo(Variant::INT, "id")));
    ADD_SIGNAL(MethodInfo("_device_connected_on_port", PropertyInfo(Variant::INT, "id"), PropertyInfo(Variant::INT, "port")));
    ADD_SIGNAL(MethodInfo("_device_packet_received_on_port",
        PropertyInfo(Variant::INT, "id"), 
        PropertyInfo(Variant::INT, "port"),
        PropertyInfo(Variant::INT, "time"),
        PropertyInfo(Variant::POOL_BYTE_ARRAY, "packet")
    ));

    ClassDB::bind_method(D_METHOD("_ready_native"), &MidiIn::_ready_native);
    ClassDB::bind_method(D_METHOD("_midi_not_available_native"), &MidiIn::_midi_not_available_native);
    ClassDB::bind_method(D_METHOD("_device_added_native", "id", "name"), &MidiIn::_device_added_native);
    ClassDB::bind_method(D_METHOD("_device_removed_native", "id"), &MidiIn::_device_removed_native);
    ClassDB::bind_method(D_METHOD("_device_connected_on_port_native", "id", "port"), &MidiIn::_device_connected_on_port_native);
    ClassDB::bind_method(D_METHOD("_device_packet_received_on_port_native", "id", "port", "time", "packet"), &MidiIn::_device_packet_received_on_port_native);

#if defined(IPHONE_ENABLED) || defined(OSX_ENABLED)
    Engine::get_singleton()->add_singleton(Engine::Singleton("MidiInGodot", memnew(MidiInGodot)));
#endif
}
