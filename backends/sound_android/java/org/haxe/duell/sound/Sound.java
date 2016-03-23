/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.haxe.duell.sound;

import android.util.Log;
import org.haxe.duell.hxjni.HaxeObject;
import org.haxe.duell.sound.helper.SoundIdProvider;
import org.haxe.duell.sound.listener.OnSoundCompleteListener;
import org.haxe.duell.sound.listener.OnSoundReadyListener;
import org.haxe.duell.sound.manager.SoundManager;

public final class Sound implements OnSoundReadyListener, OnSoundCompleteListener
{
    private static final String TAG = Sound.class.getSimpleName();

    private final HaxeObject haxeSound;
    private final String fileUrl;
    private final boolean fromAssets;
    private final int uniqueKey;

    private int id;
    private float volume;
    private int loop;
    private SoundState state;

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
        uniqueKey = SoundIdProvider.getId();

        volume = 1.0f;
        loop = 0;

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

        switch (state)
        {
            case UNLOADED:
                preloadSound(true);
                // fall-through is intended to return

            case LOADING:
                return;

            case PAUSED:
                SoundManager.getSharedInstance().resumeSound(this);
                break;

            case IDLE:
                SoundManager.getSharedInstance().playSound(this);
                break;

            default:
                break;
        }

        // set it as idle to be sure, as there is no way to identify when it is playing or when it is actually idle
        state = SoundState.IDLE;
    }

    public void stopSound()
    {
        Log.d(TAG, "Sound stopped");

        if (state == SoundState.UNLOADED || state == SoundState.LOADING)
        {
            return;
        }

        state = SoundState.IDLE;

        SoundManager.getSharedInstance().stopSound(this);
    }

    public void pauseSound()
    {
        Log.d(TAG, "Sound paused");

        if (state != SoundState.IDLE)
        {
            return;
        }

        state = SoundState.PAUSED;

        SoundManager.getSharedInstance().pauseSound(this);
    }

    public void setVolume(final float volume)
    {
        Log.d(TAG, "Set volume: " + volume);

        this.volume = volume;

        if (state != SoundState.UNLOADED)
        {
            // update immediately if the sound is loaded
            SoundManager.getSharedInstance().setSoundVolume(this, volume);
        }
    }

    public void setLoop(final int loop)
    {
        Log.d(TAG, "Set loop: " + loop);

        this.loop = loop;
    }

    public void unload()
    {
        id = -1;
        state = SoundState.UNLOADED;
    }

    @Override
    public void onSoundReady(final int soundId, final long soundDurationMillis)
    {
        Log.d(TAG, "Sound ready! ID: " + soundId);

        id = soundId;
        state = SoundState.IDLE;

        haxeSound.call0("onSoundLoadCompleted");

        if (playAfterPreload)
        {
            playSound();
        }
    }

    @Override
    public void onSoundComplete()
    {
        // will never get called, but the sound is always IDLE independently of whether it's playing or actually idle
        state = SoundState.IDLE;
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

    public int getLoopCount()
    {
        return loop;
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
