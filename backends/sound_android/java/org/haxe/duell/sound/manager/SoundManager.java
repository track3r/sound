/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.sound.manager;

import android.annotation.TargetApi;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.util.Log;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.sound.Sound;

import java.io.IOException;
import java.lang.ref.WeakReference;

/**
 * @author jxav
 */
@TargetApi(Build.VERSION_CODES.FROYO)
public final class SoundManager implements AudioManager.OnAudioFocusChangeListener
{
    private static final String TAG = SoundManager.class.getSimpleName();
    private static final float LOW_VOLUME = 0.1f;

    private static SoundManager instance = null;

    private MediaPlayerState playerState;
    private MediaPlayer player;

    private Sound lastSound;
    private float playerVolume;

    private final WeakReference<AssetManager> assetManager;

    public static SoundManager getSharedInstance()
    {
        if (instance == null)
        {
            instance = new SoundManager();
        }

        return instance;
    }

    private SoundManager()
    {
        assetManager = new WeakReference<AssetManager>(DuellActivity.getInstance().getAssets());

        create();
    }

    //
    // Lifecycle and focus handling
    //

    private void create()
    {
        player = new MediaPlayer();
        player.setAudioStreamType(AudioManager.STREAM_MUSIC);
        player.setOnErrorListener(new MediaPlayer.OnErrorListener()
        {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra)
            {
                playerState = MediaPlayerState.ERROR;

                reset();

                return false;
            }
        });

        reset();

        FocusManager.request(this);
    }

    private void release()
    {
        FocusManager.release(this);

        if (player != null)
        {
            playerState = MediaPlayerState.END;
            player.release();
            player = null;
        }
    }

    @Override
    public void onAudioFocusChange(final int focusChange)
    {
        switch (focusChange)
        {
            case AudioManager.AUDIOFOCUS_GAIN:
                // resume playback
                if (playerState == MediaPlayerState.STARTED || playerState == MediaPlayerState.PAUSED)
                {
                    play(lastSound);
                }

                // set the old volume
                setVolume(playerVolume);

                break;

            case AudioManager.AUDIOFOCUS_LOSS:
                // Lost focus for an unbounded amount of time: stop playback and release media player
                reset();
                release();

                break;

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                // Lost focus for a short time, but we have to stop playback. We don't release the media player
                // because playback is likely to resume
                if (playerState == MediaPlayerState.STARTED)
                {
                    pause();
                }

                break;

            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                // Lost focus for a short time, but it's ok to keep playing at an attenuated level
                if (playerVolume < LOW_VOLUME && player != null)
                {
                    player.setVolume(LOW_VOLUME, LOW_VOLUME);
                }

                break;
        }
    }

    //
    // State handling
    //

    public synchronized boolean initializeSound(final Sound sound)
    {
        AssetManager assets = assetManager.get();

        // if asset manager is null, we're in a VERY bad state
        if (assets == null)
        {
            return false;
        }

        // recreate player if needed, we're in a recoverable state since initialize operates from IDLE
        if (player == null)
        {
            create();
        }

        // if player is already playing, force it to go back to the idle state
        if (player.isPlaying())
        {
            stop();
            reset();
        }

        String fileUrl = sound.getFileUrl();

        // we're using the AssetManager, so we are automatically inside the path
        if (fileUrl.startsWith("assets/"))
        {
            fileUrl = fileUrl.substring(7);
        }

        try
        {
            // load the file and set it as a data source in the player
            AssetFileDescriptor afd = assets.openFd(fileUrl);
            player.setDataSource(afd.getFileDescriptor());
            playerState = MediaPlayerState.INITIALIZED;
            afd.close();

            replaceSound(sound);

            prepareSound(sound, false);
        } catch (IOException e)
        {
            Log.e(TAG, e.getMessage());
            return false;
        }

        return true;
    }

    private void prepareSound(final Sound sound, final boolean shouldPlay)
    {
        if (player != null)
        {
            // bind the prepare listener for THIS particular instance of sound
            player.setOnPreparedListener(new MediaPlayer.OnPreparedListener()
            {
                @Override
                public void onPrepared(MediaPlayer mp)
                {
                    playerState = MediaPlayerState.PREPARED;

                    // if it should play, do so immediately, otherwise notify the listeners
                    if (shouldPlay)
                    {
                        play(sound);
                    } else
                    {
                        sound.onSoundReady(sound, getCurrentSoundDuration());
                    }
                }
            });

            // prepare the sound
            playerState = MediaPlayerState.PREPARING;
            player.prepareAsync();
        }
    }

    public void play(final Sound sound)
    {
        FocusManager.request(this);

        // recreate player if needed, we're in a recoverable state
        if (player == null)
        {
            create();
        }

        if (playerState == MediaPlayerState.IDLE || lastSound != sound)
        {
            // we are changing songs, if it is playing, stop the current song
            if (player.isPlaying())
            {
                stop();
            }

            // player is in an idle state, so we reset before initializing a sound
            reset();
            initializeSound(sound);
            return;
        }

        if (!isAbleToPlay())
        {
            // if the current state means that we are not able to play (but not idle, then move it to stop and to
            // prepare, to be played when possible
            stop();
            prepareSound(sound, true);
            return;
        }

        playerState = MediaPlayerState.STARTED;

        player.start();

        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener()
        {
            @Override
            public void onCompletion(MediaPlayer mp)
            {
                FocusManager.onSoundComplete(SoundManager.this);

                playerState = MediaPlayerState.PLAYBACK_COMPLETED;

                sound.onSoundComplete(sound);
            }
        });
    }

    public void stop()
    {
        FocusManager.release(this);

        if (player != null)
        {
            playerState = MediaPlayerState.STOPPED;
            player.stop();
        }
    }

    public void pause()
    {
        FocusManager.release(this);

        if (player != null)
        {
            playerState = MediaPlayerState.PAUSED;
            player.pause();
        }
    }

    private void reset()
    {
        replaceSound(null);

        if (player != null)
        {
            playerState = MediaPlayerState.IDLE;
            player.reset();
        }
    }

    //
    // Non-state affecting
    //

    public void setVolume(final float volume)
    {
        if (player != null)
        {
            playerVolume = volume;
            player.setVolume(volume, volume);
        }
    }

    public void setLoop(final boolean loop)
    {
        if (player != null)
        {
            player.setLooping(loop);
        }
    }

    public long getCurrentSoundDuration()
    {
        return player.getDuration();
    }

    public long getCurrentSoundPosition()
    {
        return player.getCurrentPosition();
    }

    //
    // Helpers
    //

    private void replaceSound(final Sound sound)
    {
        if (lastSound != null)
        {
            lastSound.unload();
        }

        lastSound = sound;
    }

    private boolean isAbleToPlay()
    {
        return playerState == MediaPlayerState.PREPARED || playerState == MediaPlayerState.STARTED ||
                playerState == MediaPlayerState.PAUSED || playerState == MediaPlayerState.PLAYBACK_COMPLETED;
    }
}
