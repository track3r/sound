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

    private final HaxeObject haxeSound;
    private final String fileUrl;

    private float volume;
    private boolean loop;
    private SoundState state;

    private long duration;
    private long position;

    private boolean playAfterPreload;

    public static Sound create(final HaxeObject haxeObject, final String fileUrl)
    {
        return new Sound(haxeObject, fileUrl);
    }

    private Sound(final HaxeObject haxeSound, final String fileUrl)
    {
        this.haxeSound = haxeSound;
        this.fileUrl = fileUrl;

        volume = 1.0f;
        loop = false;
        state = SoundState.UNLOADED;

        duration = -1;
        position = 0;

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

        SoundManager.getSharedInstance().initializeSound(this);
    }

    public void playSound()
    {
        Log.d(TAG, "Sound playing");

        if (state == SoundState.UNLOADED)
        {
            preloadSound(true);
            return;
        } else if (state != SoundState.IDLE)
        {
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

        // reset sound position
        position = 0;
    }

    public void pauseSound()
    {
        Log.d(TAG, "Sound paused");

        if (state != SoundState.PLAYING) {
            return;
        }

        state = SoundState.IDLE;

        SoundManager.getSharedInstance().pause();

        // cache current sound position on pause
        position = SoundManager.getSharedInstance().getCurrentSoundPosition();
    }

    public void setVolume(final float volume)
    {
        Log.d(TAG, "Set volume: " + volume);

        this.volume = volume;

        if (state != SoundState.UNLOADED)
        {
            // update immediately if the sound is loaded
            SoundManager.getSharedInstance().setVolume(volume);
        }
    }

    public void setLoop(final boolean loop)
    {
        Log.d(TAG, "Set loop: " + loop);

        this.loop = loop;

        if (state != SoundState.UNLOADED)
        {
            // update immediately if the sound is loaded
            SoundManager.getSharedInstance().setLoop(loop);
        }
    }

    public float getDuration()
    {
        Log.d(TAG, "Get duration");

        if (duration == -1 && state != SoundState.UNLOADED)
        {
            // update the duration value, if it is still the default value
            duration = SoundManager.getSharedInstance().getCurrentSoundDuration();
        }

        return duration;
    }

    public float getPosition()
    {
        Log.d(TAG, "Get position");

        if (state == SoundState.PLAYING)
        {
            // always cache the last position in case it changes state too quickly
            position = SoundManager.getSharedInstance().getCurrentSoundPosition();
        }

        return position;
    }

    public void unload()
    {
        state = SoundState.UNLOADED;
        position = 0;
    }

    @Override
    public void onSoundReady(final Sound sound, final long soundDurationMillis)
    {
        duration = soundDurationMillis;
        state = SoundState.IDLE;

        haxeSound.call0("onSoundLoadCompleted");

        if (playAfterPreload)
        {
            playSound();
        }
    }

    @Override
    public void onSoundComplete(final Sound sound)
    {
        position = (long) getDuration();
        state = SoundState.IDLE;

        haxeSound.call0("onPlaybackCompleted");
    }

    public String getFileUrl()
    {
        return fileUrl;
    }
}
