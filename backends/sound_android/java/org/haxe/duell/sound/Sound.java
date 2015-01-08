/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.sound;

import android.util.Log;
import org.haxe.duell.hxjni.HaxeObject;
import org.haxe.duell.sound.listener.OnSoundCompleteListener;
import org.haxe.duell.sound.listener.OnSoundReadyListener;
import org.haxe.duell.sound.manager.SoundManager;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author jxav
 */
public final class Sound implements OnSoundReadyListener, OnSoundCompleteListener
{
    private static final String TAG = Sound.class.getSimpleName();

    private static final AtomicInteger ID_GENERATOR = new AtomicInteger(0);

    private final HaxeObject haxeSound;
    private final String fileUrl;
    private final boolean fromAssets;
    private final int uniqueKey;

    private int id;
    private float volume;
    private boolean looped;
    private SoundState state;

    private long duration;
    private long position;

    private boolean playAfterPreload;

    public static Sound create(final HaxeObject haxeObject, final String fileUrl, final boolean fromAssets)
    {
        return new Sound(haxeObject, fileUrl, fromAssets);
    }

    private Sound(final HaxeObject haxeSound, final String fileUrl, final boolean fromAssets)
    {
        this.haxeSound = haxeSound;
        this.fileUrl = fileUrl;
        this.fromAssets = fromAssets;

        // the unique id has to be different for every sound, so a hash of file URL is not sufficient
        uniqueKey = ID_GENERATOR.getAndIncrement();

        duration = -1;
        volume = 1.0f;
        looped = false;

        unload();

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
        }
        /** TODO: music handling
         else if (state != SoundState.IDLE)
         {
         return;
         }

         state = SoundState.PLAYING; */
        else if (state == SoundState.LOADING)
        {
            return;
        }

        SoundManager.getSharedInstance().playSound(this);
    }

    public void stopSound()
    {
        Log.d(TAG, "Sound stopped");

        /** TODO: music handling
         if (state != SoundState.PLAYING)
         {
         return;
         } */

        if (state == SoundState.UNLOADED || state == SoundState.LOADING)
        {
            return;
        }

        state = SoundState.IDLE;

        SoundManager.getSharedInstance().stopSound(this);

        /** TODO: music handling
         // reset sound position
         position = 0;
         */
    }

    public void pauseSound()
    {
        Log.d(TAG, "Sound paused");

        /** TODO: music handling
         if (state != SoundState.PLAYING)
         {
         return;
         } */

        if (state == SoundState.UNLOADED || state == SoundState.LOADING)
        {
            return;
        }

        state = SoundState.IDLE;

        SoundManager.getSharedInstance().pauseSound(this);

        /** TODO: music handling
         // cache current sound position on pause
         position = SoundManager.getSharedInstance().getCurrentMusicPosition();
         */
    }

    public void setVolume(final float volume)
    {
        Log.d(TAG, "Set volume: " + volume);

        this.volume = volume;

        /** TODO: music handling
         if (state != SoundState.UNLOADED)
         {
         // update immediately if the sound is loaded
         SoundManager.getSharedInstance().setMusicVolume(volume);
         } */
    }

    public void setLooped(final boolean looped)
    {
        Log.d(TAG, "Set looped: " + looped);

        this.looped = looped;

        /** TODO: music handling
         if (state != SoundState.UNLOADED)
         {
         // update immediately if the sound is loaded
         SoundManager.getSharedInstance().setMusicLoop(loop);
         } */
    }

    public float getDuration()
    {
        Log.d(TAG, "Get duration");

        /** TODO: music handling
         if (duration == -1 && state != SoundState.UNLOADED)
         {
         // update the duration value, if it is still the default value
         duration = SoundManager.getSharedInstance().getCurrentMusicDuration();
         } */

        return duration;
    }

    public float getPosition()
    {
        Log.d(TAG, "Get position");

        /** TODO: music handling
         if (state == SoundState.PLAYING)
         {
         // always cache the last position in case it changes state too quickly
         position = SoundManager.getSharedInstance().getCurrentMusicPosition();
         } */

        return position;
    }

    public void unload()
    {
        id = -1;
        state = SoundState.UNLOADED;
        position = 0;
    }

    @Override
    public void onSoundReady(final Sound sound, final int soundId, final long soundDurationMillis)
    {
        Log.d(TAG, "Sound ready! ID: " + soundId);

        id = soundId;
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

    //
    // Getters
    //

    public boolean isReady()
    {
        return state != SoundState.UNLOADED;
    }

    public String getFileUrl()
    {
        return fileUrl;
    }

    public boolean isLooped()
    {
        return looped;
    }

    public float getVolume()
    {
        return volume;
    }

    public int getId()
    {
        return id;
    }

    public int getUniqueKey()
    {
        return uniqueKey;
    }

    public boolean isFromAssets()
    {
        return fromAssets;
    }
}
