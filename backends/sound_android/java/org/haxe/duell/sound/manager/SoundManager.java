/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.sound.manager;

import android.annotation.TargetApi;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.os.Build;
import android.util.Log;
import android.util.SparseArray;
import android.util.SparseIntArray;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.sound.Sound;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

/**
 * @author jxav
 */
@TargetApi(Build.VERSION_CODES.GINGERBREAD)
public final class SoundManager implements AudioManager.OnAudioFocusChangeListener
{
    private static final String TAG = SoundManager.class.getSimpleName();
    private static final float LOW_VOLUME = 0.1f;
    private static final int MAX_STREAMS = 3;

    private static SoundManager instance = null;

    private MediaPlayerState playerState;
    private MediaPlayer player;
    private float playerVolume;
    private Sound lastMusic;

    private SoundPool sfxPool;
    private final SparseIntArray soundStreams;
    private final SparseArray<Sound> loadedSounds;
    private final Deque<Integer> soundLoadQueue;

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
        soundStreams = new SparseIntArray();
        loadedSounds = new SparseArray<Sound>();
        soundLoadQueue = new ArrayDeque<Integer>();

        create();
    }

    //
    // Lifecycle and focus handling
    //

    private void create()
    {
        soundStreams.clear();
        loadedSounds.clear();
        soundLoadQueue.clear();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            loadSfxPool();
        } else
        {
            loadSfxPoolCompat();
        }

        sfxPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener()
        {
            @Override
            public void onLoadComplete(SoundPool soundPool, int sampleId, int status)
            {
                // success
                if (status == 0)
                {
                    int soundKey = soundLoadQueue.removeLast();
                    Sound sound = loadedSounds.get(soundKey);

                    // duration unknown
                    sound.onSoundReady(sound, sampleId, 0);
                }
            }
        });

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

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void loadSfxPool()
    {
        AudioAttributes attributes = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .build();

        sfxPool = new SoundPool.Builder()
                .setMaxStreams(MAX_STREAMS)
                .setAudioAttributes(attributes)
                .build();
    }

    private void loadSfxPoolCompat()
    {
        sfxPool = new SoundPool(MAX_STREAMS, AudioManager.STREAM_MUSIC, 0);
    }

    private void release()
    {
        FocusManager.release(this);

        for (int index = 0; index != loadedSounds.size(); index++)
        {
            loadedSounds.get(loadedSounds.keyAt(index)).unload();
        }

        loadedSounds.clear();

        if (sfxPool != null)
        {
            sfxPool.release();
            sfxPool = null;
        }

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
                    playMusic(lastMusic);
                }

                // set the old volume
                setMusicVolume(playerVolume);

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
                    pauseMusic();
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

    private void reset()
    {
        replaceMusic(null);

        if (player != null)
        {
            playerState = MediaPlayerState.IDLE;
            player.reset();
        }
    }

    //
    // Sound Pool
    //

    public synchronized boolean initializeSound(final Sound sound)
    {
        return prepareSound(sound, false);
    }

    private boolean prepareSound(final Sound sound, final boolean shouldPlay)
    {
        AssetManager assets = assetManager.get();

        // if asset manager is null, we're in a VERY bad state
        if (assets == null)
        {
            return false;
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

            soundLoadQueue.push(sound.getInternalKey());
            loadedSounds.put(sound.getInternalKey(), sound);
            sfxPool.load(afd, 1);

            afd.close();
        } catch (IOException e)
        {
            Log.e(TAG, e.getMessage());
            return false;
        }

        return true;
    }

    public void playSound(Sound sound)
    {
        // we may not have focus, so we have to acquire it briefly
        FocusManager.requestTemporary(this);

        if (sound.isReady())
        {
            Log.d(TAG, "Playing sound: " + sound.getId());

            // -1 means loop forever
            int stream = sfxPool.play(sound.getId(), sound.getVolume(), sound.getVolume(), 1, sound.isLooped() ? -1 : 0, 1.0f);

            if (stream > 0)
            {
                soundStreams.put(sound.getId(), stream);
            } else {
                // if stream is 0, it failed
                soundStreams.delete(sound.getId());
            }
        }
    }

    public void stopSound(Sound sound)
    {
        Log.d(TAG, "Stopping sound: " + sound.getId());

        int stream = soundStreams.get(sound.getId(), -1);

        if (stream != -1)
        {
            sfxPool.stop(stream);
            soundStreams.delete(sound.getId());
        }
    }

    public void pauseSound(Sound sound)
    {
        // TODO later sfxPool.pause(soundStreams.get(sound.getId()));
    }










    //
    // Player settings (TODO later)
    //

    //
    // State handling
    //

    public synchronized boolean initializeMusic(final Sound sound)
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
            stopMusic();
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

            replaceMusic(sound);

            prepareMusic(sound, false);
        } catch (IOException e)
        {
            Log.e(TAG, e.getMessage());
            return false;
        }

        return true;
    }

    private void prepareMusic(final Sound sound, final boolean shouldPlay)
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
                        playMusic(sound);
                    } else
                    {
                        sound.onSoundReady(sound, -1, getCurrentMusicDuration());
                    }
                }
            });

            // prepare the sound
            playerState = MediaPlayerState.PREPARING;
            player.prepareAsync();
        }
    }

    public void playMusic(final Sound sound)
    {
        FocusManager.request(this);

        // recreate player if needed, we're in a recoverable state
        if (player == null)
        {
            create();
        }

        if (playerState == MediaPlayerState.IDLE || lastMusic != sound)
        {
            // we are changing songs, if it is playing, stop the current song
            if (player.isPlaying())
            {
                stopMusic();
            }

            // player is in an idle state, so we reset before initializing a sound
            reset();
            initializeMusic(sound);
            return;
        }

        if (!isAbleToPlayMusic())
        {
            // if the current state means that we are not able to play (but not idle, then move it to stop and to
            // prepare, to be played when possible
            stopMusic();
            prepareMusic(sound, true);
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

    public void stopMusic()
    {
        FocusManager.release(this);

        if (player != null)
        {
            playerState = MediaPlayerState.STOPPED;
            player.stop();
        }
    }

    public void pauseMusic()
    {
        FocusManager.release(this);

        if (player != null)
        {
            playerState = MediaPlayerState.PAUSED;
            player.pause();
        }
    }

    //
    // Non-state affecting
    //

    public void setMusicVolume(final float volume)
    {
        if (player != null)
        {
            playerVolume = volume;
            player.setVolume(volume, volume);
        }
    }

    public void setMusicLoop(final boolean loop)
    {
        if (player != null)
        {
            player.setLooping(loop);
        }
    }

    public long getCurrentMusicDuration()
    {
        return player.getDuration();
    }

    public long getCurrentMusicPosition()
    {
        return player.getCurrentPosition();
    }

    //
    // Helpers
    //

    private void replaceMusic(final Sound sound)
    {
        if (lastMusic != null)
        {
            lastMusic.unload();
        }

        lastMusic = sound;
    }

    private boolean isAbleToPlayMusic()
    {
        return playerState == MediaPlayerState.PREPARED || playerState == MediaPlayerState.STARTED ||
                playerState == MediaPlayerState.PAUSED || playerState == MediaPlayerState.PLAYBACK_COMPLETED;
    }
}
