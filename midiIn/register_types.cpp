#include "register_types.h"

#include <core/engine.h>
#include "apple/src/midiIn.h"

void register_midiIn_types() {
    Engine::get_singleton()->add_singleton(Engine::Singleton("MidiIn", memnew(MidiIn)));
}

void unregister_midiIn_types() {
}