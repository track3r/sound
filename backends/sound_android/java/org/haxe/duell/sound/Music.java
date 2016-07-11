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
import org.haxe.duell.sound.listener.OnSoundCompleteListener;
import org.haxe.duell.sound.listener.OnSoundReadyListener;
import org.haxe.duell.sound.manager.FocusManager;
import org.haxe.duell.sound.manager.SoundManager;
import org.haxe.duell.DuellActivity;

public final class Music implements OnSoundReadyListener, OnSoundCompleteListener
{
    private static final String TAG = Music.class.getSimpleName();

    private final HaxeObject haxeMusic;
    private final String fileUrl;

    private float volume;
    private boolean looped;
    private SoundState state;

    private long duration;
    private long position;

    private boolean playAfterPreload;

    private static boolean allowNativePlayer = true;

    public static Music create(final HaxeObject haxeObject, final String fileUrl)
    {
        return new Music(haxeObject, fileUrl);
    }

    private Music(final HaxeObject haxeMusic, final String fileUrl)
    {
        this.haxeMusic = haxeMusic;
        this.fileUrl = fileUrl;

        duration = -1;
        volume = 1.0f;
        looped = false;

        unload();

        Log.d(TAG, "Music created for file: " + fileUrl);
    }

    public void preloadMusic(final boolean playAfterPreload)
    {
        Log.d(TAG, "Music is preloading");

        if (state != SoundState.UNLOADED)
        {
            return;
        }

        state = SoundState.LOADING;
        this.playAfterPreload = playAfterPreload;

        SoundManager.getSharedInstance().initializeMusic(this);
    }

    public void playMusic()
    {
        // the native player could have stopped so we check if ANY music is currently playing.
        boolean isMusicPlaying = FocusManager.isMusicPlaying();
        boolean isNativePlayerPlaying = SoundManager.getSharedInstance().isNativePlayerPlaying;

        if (allowNativePlayer && isNativePlayerPlaying && isMusicPlaying)
        {
            return;
        }

        Log.d(TAG, "Music playing");

        if (state == SoundState.UNLOADED)
        {
            preloadMusic(true);
            return;
        }
        else if (state != SoundState.IDLE && state != SoundState.PAUSED)
        {
            return;
        }

        state = SoundState.PLAYING;

        SoundManager.getSharedInstance().playMusic(this);
    }

    public void stopMusic()
    {
        Log.d(TAG, "Music stopped");

        if (state != SoundState.PLAYING && state != SoundState.PAUSED)
        {
            return;
        }

        state = SoundState.IDLE;

        SoundManager.getSharedInstance().stopMusic();

        // reset sound position
        position = 0;
    }

    public void pauseMusic()
    {
        Log.d(TAG, "Music paused");

        if (state != SoundState.PLAYING)
        {
            return;
        }

        state = SoundState.PAUSED;

        SoundManager.getSharedInstance().pauseMusic();

        // cache current sound position on pause
        position = SoundManager.getSharedInstance().getCurrentMusicPosition();
    }

    public void setVolume(final float volume)
    {
        Log.d(TAG, "Set volume: " + volume);

        this.volume = volume;

        if (state != SoundState.UNLOADED)
        {
            // update immediately if the sound is loaded
            SoundManager.getSharedInstance().setMusicVolume(volume);
        }
    }

    public void setLooped(final boolean looped)
    {
        Log.d(TAG, "Set looped: " + looped);

        this.looped = looped;

        if (state != SoundState.UNLOADED)
        {
            // update immediately if the sound is loaded
            SoundManager.getSharedInstance().setMusicLoop(looped);
        }
    }

    public static void setAllowNativePlayer(final boolean _allowNativePlayer)
    {
        allowNativePlayer = _allowNativePlayer;

        if (!allowNativePlayer)
        {
            // if native player is not allow it shall be silenced
            boolean isNativePlayerPlaying = SoundManager.getSharedInstance().isNativePlayerPlaying;
            SoundManager.getSharedInstance().isNativePlayerPlaying = false;

            SoundManager.getSharedInstance().requestFocus();
        }
    }

    public float getDuration()
    {
        Log.d(TAG, "Get duration");

        if (duration == -1 && state != SoundState.UNLOADED)
        {
            // update the duration value, if it is still the default value
            duration = SoundManager.getSharedInstance().getCurrentMusicDuration();
        }

        return duration;
    }

    public float getPosition()
    {
        Log.d(TAG, "Get position");

        if (state == SoundState.PLAYING)
        {
            // always cache the last position in case it changes state too quickly
            position = SoundManager.getSharedInstance().getCurrentMusicPosition();
        }

        return position;
    }

    public void unload()
    {
        state = SoundState.UNLOADED;
        position = 0;
    }

    @Override
    public void onSoundReady(final int soundId, final long soundDurationMillis)
    {
        Log.d(TAG, "Music ready! ID: " + soundId);

        duration = soundDurationMillis;
        state = SoundState.IDLE;


        DuellActivity.getInstance().queueOnHaxeRunloop(new Runnable() {
            @Override
            public void run() {
                haxeMusic.call0("onMusicLoadCompleted");
            }
        });


        if (playAfterPreload)
        {
            playMusic();
        }
    }

    @Override
    public void onSoundComplete()
    {
        Log.d(TAG, "Music complete!");

        if (looped)
        {
            position = 0;
            // state is unaffected
        }
        else
        {
            position = (long) getDuration();
            state = SoundState.IDLE;
        }

        DuellActivity.getInstance().queueOnHaxeRunloop(new Runnable() {
            @Override
            public void run()
            {
                haxeMusic.call0("onPlaybackCompleted");
            }
        });

    }

    //
    // Getters
    //

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
}
