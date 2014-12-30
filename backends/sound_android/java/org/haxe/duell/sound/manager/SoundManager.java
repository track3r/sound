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

    public synchronized boolean preloadSound(final Sound sound)
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

            // bind the prepare listener for THIS particular instance of sound
            player.setOnPreparedListener(new MediaPlayer.OnPreparedListener()
            {
                @Override
                public void onPrepared(MediaPlayer mp)
                {
                    playerState = MediaPlayerState.PREPARED;
                    sound.onSoundReady(sound);
                }
            });

            // prepare the sound
            playerState = MediaPlayerState.PREPARING;
            player.prepareAsync();
        } catch (IOException e)
        {
            Log.e(TAG, e.getMessage());
            return false;
        }

        return true;
    }

    public void play(final Sound sound)
    {
        if (playerState == MediaPlayerState.IDLE)
        {
            preloadSound(sound);
            return;
        } else if (player != null && player.isPlaying())
        {
            // for any possible state of play, if the player is already playing whatever sound, stop and play new one
            stop();
            play(sound);
            return;
        }

        if (player != null && isAbleToPlay())
        {
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
    }

    private void reset() {
        playerState = MediaPlayerState.IDLE;
        player.reset();
    }

    public void stop()
    {
        if (player != null)
        {
            playerState = MediaPlayerState.STOPPED;
            player.stop();

            reset();
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

    private boolean isAbleToPlay() {
        return playerState == MediaPlayerState.PREPARED || playerState == MediaPlayerState.STARTED ||
                playerState ==  MediaPlayerState.PAUSED || playerState == MediaPlayerState.PLAYBACK_COMPLETED;
    }
}
