package org.haxe.duell.sound.manager;

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.util.Log;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.sound.Sound;

import java.io.IOException;
import java.lang.ref.WeakReference;

/**
 * @author jxav
 * Copyright (c) 2014 GameDuell GmbH
 */
public final class SoundManager
{
    private static final String TAG = SoundManager.class.getSimpleName();

    private static SoundManager instance = null;

    private MediaPlayerState playerState;
    private MediaPlayer player;

    private Sound lastSound;

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

    private void create()
    {
        player = new MediaPlayer();
        player.setAudioStreamType(AudioManager.STREAM_MUSIC);
        player.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                playerState = MediaPlayerState.ERROR;
                return false;
            }
        });

        reset();
    }

    public synchronized boolean initializeSound(final Sound sound)
    {
        AssetManager assets = assetManager.get();

        // if player is not set or asset manager was called, we're in a VERY bad state
        if (player == null || assets == null)
        {
            return false;
        }

        // if player is already playing, force it to go back to the idle state
        if (player.isPlaying())
        {
            stop();
            reset();
        }

        String fileUrl = sound.getFileUrl();

        if (fileUrl.startsWith("assets/")) {
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

    private void replaceSound(Sound sound) {
        if (lastSound != null)
        {
            lastSound.unload();
        }

        lastSound = sound;
    }

    private void prepareSound(final Sound sound, final boolean shouldPlay) {
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

    public void play(final Sound sound)
    {
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
                playerState = MediaPlayerState.PLAYBACK_COMPLETED;

                stop();

                sound.onSoundComplete(sound);
            }
        });
    }

    private void reset()
    {
        lastSound = null;

        playerState = MediaPlayerState.IDLE;
        player.reset();
    }

    public void stop()
    {
        if (player != null)
        {
            playerState = MediaPlayerState.STOPPED;
            player.stop();
        }
    }

    public void pause()
    {
        if (player != null)
        {
            playerState = MediaPlayerState.PAUSED;
            player.pause();
        }
    }

    public void setVolume(final float volume)
    {
        if (player != null)
        {
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

    private boolean isAbleToPlay()
    {
        return playerState == MediaPlayerState.PREPARED || playerState == MediaPlayerState.STARTED ||
                playerState ==  MediaPlayerState.PAUSED || playerState == MediaPlayerState.PLAYBACK_COMPLETED;
    }
}
