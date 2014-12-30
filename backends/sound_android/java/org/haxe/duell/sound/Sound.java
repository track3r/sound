package org.haxe.duell.sound;

import android.util.Log;
import org.haxe.duell.hxjni.HaxeObject;
import org.haxe.duell.sound.listener.OnSoundCompleteListener;
import org.haxe.duell.sound.listener.OnSoundReadyListener;
import org.haxe.duell.sound.manager.SoundManager;

/**
 * @author jxav
 * Copyright (c) 2014 GameDuell GmbH
 */
public final class Sound implements OnSoundReadyListener, OnSoundCompleteListener
{
    private static final String TAG = Sound.class.getSimpleName();

    private final HaxeObject haxeObject;
    private final String fileUrl;

    private float volume;
    private boolean loop;
    private SoundState state;

    private boolean playAfterPreload;

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

    public void preloadSound(final boolean playAfterPreload)
    {
        Log.d(TAG, "Sound is preloading");

        if (state != SoundState.UNLOADED)
        {
            return;
        }

        state = SoundState.LOADING;
        this.playAfterPreload = playAfterPreload;

        SoundManager.getSharedInstance().preloadSound(this);
    }

    public void playSound()
    {
        Log.d(TAG, "Sound playing");

        if (state == SoundState.UNLOADED) {
            preloadSound(true);
            return;
        } else if (state != SoundState.IDLE) {
            return;
        }

        state = SoundState.PLAYING;

        SoundManager mgr = SoundManager.getSharedInstance();
        mgr.setLoop(loop);
        mgr.setVolume(volume);
        mgr.play(this);
    }

    public void stopSound()
    {
        Log.d(TAG, "Sound stopped");

        if (state != SoundState.PLAYING) {
            return;
        }

        state = SoundState.IDLE;

        SoundManager.getSharedInstance().stop();
    }

    public void setVolume(final float volume)
    {
        Log.d(TAG, "Set volume: " + volume);

        this.volume = volume;

        if (state == SoundState.PLAYING)
        {
            SoundManager.getSharedInstance().setVolume(volume);
        }
    }

    public void setLoop(final boolean loop)
    {
        Log.d(TAG, "Set loop: " + loop);

        this.loop = loop;

        if (state == SoundState.PLAYING)
        {
            SoundManager.getSharedInstance().setLoop(loop);
        }
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

    @Override
    public void onSoundReady(final Sound sound)
    {
        state = SoundState.IDLE;

        if (playAfterPreload)
        {
            playSound();
        }
    }

    @Override
    public void onSoundComplete(final Sound sound)
    {
        state = SoundState.IDLE;

        // TODO notify haxe object
    }

    public String getFileUrl()
    {
        return fileUrl;
    }

    public boolean isReady()
    {
        return state != SoundState.UNLOADED;
    }
}
