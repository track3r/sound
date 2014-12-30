package org.haxe.duell.sound;

import android.util.Log;
import org.haxe.duell.hxjni.HaxeObject;

/**
 * @author jxav
 * Copyright (c) 2014 GameDuell GmbH
 */
public final class Sound
{
    private static final String TAG = Sound.class.getSimpleName();

    private final HaxeObject haxeObject;
    private final String fileUrl;

    private float volume;
    private boolean loop;
    private SoundState state;

    public static Sound create(final HaxeObject haxeObject, final String fileUrl)
    {
        return new Sound(haxeObject, fileUrl);
    }

    private Sound(final HaxeObject haxeObject, final String fileUrl)
    {
        this.haxeObject = haxeObject;
        this.fileUrl = fileUrl;

        volume = 1.0f;
        loop = false;
        state = SoundState.UNLOADED;

        Log.d(TAG, "Sound created for file: " + fileUrl);
    }

    public void preloadSound(final boolean playOnFinish)
    {
        Log.d(TAG, "Sound is preloading");

        // TODO
    }

    public void playSound()
    {
        Log.d(TAG, "Sound playing");

        if (state == SoundState.UNLOADED) {
            preloadSound(true);
            return;
        } else if (state == SoundState.PLAYING) {
            return;
        }

        // TODO
    }

    public void stopSound()
    {
        Log.d(TAG, "Sound stopped");

        // TODO
    }

    public void setVolume(final float volume)
    {
        Log.d(TAG, "Set volume: " + volume);

        this.volume = volume;

        // TODO
    }

    public void setLoop(final boolean loop)
    {
        Log.d(TAG, "Set loop: " + loop);

        this.loop = loop;

        // TODO
    }

    public float getLength()
    {
        Log.d(TAG, "Get length");

        // TODO
        return 0.0f;
    }

    public float getPosition()
    {
        Log.d(TAG, "Get position");

        // TODO
        return 0.0f;
    }
}
