package org.godotengine.godot;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.midi.MidiDevice;
import android.media.midi.MidiDeviceInfo;
import android.media.midi.MidiManager;
import android.media.midi.MidiOutputPort;
import android.media.midi.MidiReceiver;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

public class GodotMidiInImpl implements MidiManager.OnDeviceOpenedListener {

    private final Activity activity;
    private final Listener listener;

    private enum Signals {
        DEVICE_ADDED("_device_added_native"),
        DEVICE_REMOVED("_device_removed_native"),
        DEVICE_CONNECTED_ON_PORT("_device_connected_on_port_native"),
        DEVICE_PACKET_RECEIVED_ON_PORT("_device_packet_received_on_port_native"),
        MIDI_NOT_AVAILABLE("_midi_not_available_native");

        private final String name;

        Signals(String name) {
            this.name = name;
        }
    }

    interface Listener {
        void emit_signal(String signal, Object[] extras);
    }

    GodotMidiInImpl(Activity activity, Listener listener) {
        this.activity = activity;
        this.listener = listener;

        if (listener == null) {
            throw new NullPointerException("Thou shall not listen on null");
        }

        if (!activity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {
            emit_signal(Signals.MIDI_NOT_AVAILABLE, null, new Object[]{});
            midiManager = null;
            return;
        }

        midiManager = (MidiManager) activity.getSystemService(Context.MIDI_SERVICE);

        if (midiManager == null) {
            emit_signal(Signals.MIDI_NOT_AVAILABLE, null, new Object[]{});
            return;
        }

        MidiDeviceInfo[] devices = midiManager.getDevices();

        for (MidiDeviceInfo device : devices) {
            midiDeviceCallbackHandler.onDeviceAdded(device);
        }

        midiManager.registerDeviceCallback(midiDeviceCallbackHandler, new Handler(Looper.getMainLooper()));
    }

    private final MidiManager.DeviceCallback midiDeviceCallbackHandler = new MidiManager.DeviceCallback() {
        @Override
        public void onDeviceAdded(MidiDeviceInfo device) {
            midiManager.openDevice(device, GodotMidiInImpl.this, new Handler(Looper.getMainLooper()));
            emit_signal(Signals.DEVICE_ADDED, device, new Object[]{devicePrettyName(device)});
        }

        @Override
        public void onDeviceRemoved(MidiDeviceInfo device) {
            emit_signal(Signals.DEVICE_REMOVED, device, new Object[]{});
        }
    };

    private void emit_signal(final Signals signal, final MidiDeviceInfo info, final Object[] extra) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (info != null) {
                    Object[] extraWithDeviceId = new Object[extra.length + 1];
                    extraWithDeviceId[0] = info.getId();
                    System.arraycopy(extra, 0, extraWithDeviceId, 1, extra.length);
                    listener.emit_signal(signal.name, extraWithDeviceId);
                }
                else {
                    listener.emit_signal(signal.name, extra);
                }
            }
        });
    }

    private final MidiManager midiManager;

    public void onDestroy() {
        if (midiManager != null) {
            midiManager.unregisterDeviceCallback(midiDeviceCallbackHandler);
        }
    }

    private String devicePrettyName(MidiDeviceInfo info) {
        if (info == null) {
            return "";
        }
        Bundle deviceProperties = info.getProperties();

        int id = info.getId();
        String name = deviceProperties.getString(MidiDeviceInfo.PROPERTY_NAME);
        String product = deviceProperties.getString(MidiDeviceInfo.PROPERTY_PRODUCT);
        String manufacturer = deviceProperties.getString(MidiDeviceInfo.PROPERTY_MANUFACTURER);
        return id + "# " + product + " - " + manufacturer;
    }

    private void log(String str) {
        Log.d("godot midiIn", str);
    }

    @Override
    public void onDeviceOpened(MidiDevice midiDevice) {

        final MidiDeviceInfo deviceInfo = midiDevice.getInfo();

        MidiDeviceInfo.PortInfo[] ports = deviceInfo.getPorts();

        //Open all output ports cause ... easier for now
        for (final MidiDeviceInfo.PortInfo port : ports) {

            if (port.getType() != MidiDeviceInfo.PortInfo.TYPE_OUTPUT) {
                //Only listen on output ports
                continue;
            }

            final int portNumber = port.getPortNumber();

            MidiOutputPort outputPort = midiDevice.openOutputPort(portNumber);

            if (outputPort == null) {
                Log.w("godot midiIn", "Failed to open midi outputport " + portNumber);
                continue;
            }

            outputPort.connect(new MidiReceiver() {
                @Override
                public void onSend(byte[] bytes, int offset, int count, long timestamp) {
                    byte[] packet = new byte[count];
                    System.arraycopy(bytes, offset, packet, 0, count);
                    handlePacketFromDevice(deviceInfo, portNumber, packet, timestamp);
                }
            });
            emit_signal(Signals.DEVICE_CONNECTED_ON_PORT, deviceInfo, new Object[]{portNumber});
        }
    }

    private void handlePacketFromDevice(MidiDeviceInfo deviceInfo, int port, byte[] packet, long timestamp) {
        if (packet.length == 0) {
            //Empty packet!?
            return;
        }
        emit_signal(Signals.DEVICE_PACKET_RECEIVED_ON_PORT, deviceInfo, new Object[]{port, timestamp, packet});
    }
}