#include "register_types.h"
#include <core/reference.h>

#include "MidiIn.h"

void register_midiIn_types() {
    ClassDB::register_class<MidiIn>();
}

void unregister_midiIn_types() {}