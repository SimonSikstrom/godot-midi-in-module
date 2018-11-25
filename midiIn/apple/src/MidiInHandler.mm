
#import "MidiInHandler.h"

#include "MidiInCppListener.h"

@implementation MidiInHandler

NSString* getMidiDeviceName(MIDIObjectRef object);
SInt32 getMidiUniqueID(MIDIObjectRef object);
void MidiReadProc(const MIDIPacketList *packetList, void* readProcRefCon, void* srcConnRefCon);
void MidiNotifierProc(const MIDINotification  *message, void *refCon);

- (instancetype)initWithListener:(MidiInCppListener *) listener {
    if ((self = [super init])) {
        m_listener = listener;
        OSStatus status;
        if ((status = MIDIClientCreate(CFSTR("godot-midi-in-client"), MidiNotifierProc, self, &midiclient))) {
            NSLog(@"Error MIDIClientCreate in MidiIn module: %d", status);
            listener->_midi_not_available();
            return nil;
        }
        
        [self listAllMidiOutputDevicesAndConnect];
    }
    return self;
}

- (void) dealloc {
    ItemCount sourceCount = MIDIGetNumberOfSources();
    for (ItemCount i = 0 ; i < sourceCount ; ++i) {
        MIDIEndpointRef src = MIDIGetSource(i);
        [self removeMidiSource: src];
    }
    MIDIClientDispose(midiclient);
    [super dealloc];
}

- (void) removeMidiSource: (MIDIEndpointRef) src {
    std::map<MIDIEndpointRef, MidiDeviceSource*>::iterator found = activeDevices.find(src);
    MidiDeviceSource *source = found->second;
    MIDIPortDisconnectSource(source->port, midiclient);
    MIDIPortDispose(source->port);
    activeDevices.erase(src);
    m_listener->_device_removed(source->id);
    delete source;
}

- (void) addMidiSource: (MIDIEndpointRef) src {
    
    // Check so the devices isnt already added
    assert(activeDevices.find(src) == activeDevices.end());
    
    
    SInt32 uniqueId = getMidiUniqueID(src);
    NSString *name = getMidiDeviceName(src);
    
    m_listener->_device_added(uniqueId, [name cStringUsingEncoding:NSUTF8StringEncoding]);
    
    MIDIPortRef port;
    OSStatus status;
    if ((status = MIDIInputPortCreate(midiclient, CFSTR("midiInPort"), MidiReadProc, m_listener, &port))) {
        printf("Error trying to create MIDI output port: %d\n", status);
        return;
    }
    
    MidiDeviceSource *source = new MidiDeviceSource(uniqueId, port, src);
    
    activeDevices[src] = source;
    
    MIDIPortConnectSource(port, src, source);
    
    m_listener->_device_connected_on_port(uniqueId, port);
}

- (void) listAllMidiOutputDevicesAndConnect {
    ItemCount sourceCount = MIDIGetNumberOfSources();
    for (ItemCount i = 0 ; i < sourceCount ; ++i) {
        MIDIEndpointRef src = MIDIGetSource(i);
        [self addMidiSource: src];
    }
}

SInt32 getMidiUniqueID(MIDIObjectRef object) {
    SInt32 uniqueId;
    if (noErr != MIDIObjectGetIntegerProperty(object, kMIDIPropertyUniqueID, &uniqueId)) {
        return -1;
    }
    return uniqueId;
}

NSString* getMidiDeviceName(MIDIObjectRef object) {
    CFStringRef name = nil;
    if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name)) {
        return nil;
    }
    return (NSString *) name;
}

void MidiReadProc(const MIDIPacketList *packetList, void* readProcRefCon, void* srcConnRefCon) {
    
    MidiDeviceSource *source = (MidiDeviceSource *) srcConnRefCon;
    MidiInCppListener *listener = (MidiInCppListener *) readProcRefCon;
    
    MIDIPacket *packet = (MIDIPacket*)packetList->packet;
    int count = packetList->numPackets;
    for (int i = 0; i < count; i++) {
        std::vector<uint8_t> data(packet->data, packet->data + packet->length);
        listener->_device_packet_received_on_port(source->id, source->port, packet->timeStamp, data);
        packet = MIDIPacketNext(packet);
    }
}

void MidiNotifierProc(const MIDINotification  *message, void *refCon) {
    MidiInHandler * handler = (MidiInHandler*) refCon;
    
    if (message->messageID == kMIDIMsgObjectAdded) {
        MIDIObjectAddRemoveNotification * addNotif = (MIDIObjectAddRemoveNotification *) message;
        if (addNotif->childType == kMIDIObjectType_Source) {
            [handler addMidiSource:addNotif->child];
        }
    }
    
    if (message->messageID == kMIDIMsgObjectRemoved) {
        MIDIObjectAddRemoveNotification * addNotif = (MIDIObjectAddRemoveNotification *) message;
        if (addNotif->childType == kMIDIObjectType_Source) {
            [handler removeMidiSource:addNotif->child];
        }
    }
}


@end
