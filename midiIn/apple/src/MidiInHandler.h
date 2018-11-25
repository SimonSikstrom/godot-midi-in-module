#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#include <map>

class MidiInCppListener;

struct MidiDeviceSource {
    SInt32 id;
    MIDIPortRef port;
    MIDIEndpointRef endpoint;
    MidiDeviceSource(SInt32 id, MIDIPortRef port, MIDIEndpointRef endpoint): id(id), port(port), endpoint(endpoint) {}
};

@interface MidiInHandler: NSObject {
    MIDIClientRef midiclient;
    MidiInCppListener *m_listener;
    std::map<MIDIEndpointRef, MidiDeviceSource*> activeDevices;
}

- (instancetype)initWithListener:(MidiInCppListener *) listener;

@end
