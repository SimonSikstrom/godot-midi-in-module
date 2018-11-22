package org.godotengine.godot;

import android.app.Activity;
import android.util.Log;

import android.media.midi.MidiDeviceInfo;

public class GodotMidiIn extends Godot.SingletonBase implements GodotMidiInImpl.Listener {

    private int instance_id = 0;
    private final Activity activity;
    private GodotMidiInImpl midi;

    public void init(int instance_id) {
        this.instance_id = instance_id;
        midi = new GodotMidiInImpl(activity, this);
        Log.d("godot", "MidiIn: initialized");
    }

    public void onMainDestroy() {
        midi.onDestroy();
    }

    @Override
    public void emit_signal(String signal, Object[] extra) {
        GodotLib.calldeferred(instance_id, signal, extra);
    }

    static public Godot.SingletonBase initialize(Activity activity) {
        return new GodotMidiIn(activity);
    }

    public GodotMidiIn(Activity activity) {
        registerClass("MidiIn", new String[]{"init"});
        this.activity = activity;
    }
}
