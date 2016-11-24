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
import android.util.SparseBooleanArray;
import android.util.SparseIntArray;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.sound.Music;
import org.haxe.duell.sound.Sound;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayDeque;
import java.util.Deque;

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
    private Music lastMusic;

    private SoundPool sfxPool;
    private int sessionId;
    private final SparseIntArray soundStreams;
    private final SparseBooleanArray soundStreamsPaused;
    private final SparseArray<Sound> loadedSounds;

    private final WeakReference<AssetManager> assetManager;

    public static boolean isNativePlayerPlaying;

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
        soundStreamsPaused = new SparseBooleanArray();
        loadedSounds = new SparseArray<Sound>();

        // In order to know if the native player was playing a music before our SoundManger is initialized
        // TODO: try to find a way to know if the native player is playing at any given time
        isNativePlayerPlaying = FocusManager.isMusicPlaying();

        sessionId = -1;

        create();
    }

    //
    // Lifecycle and focus handling
    //

    private synchronized void create()
    {
        soundStreams.clear();
        loadedSounds.clear();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            loadSfxPool();
        }
        else
        {
            loadSfxPoolCompat();
        }

        sessionId++;
        final int sfxPoolSessionId = sessionId;

        sfxPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener()
        {
            @Override
            public void onLoadComplete(SoundPool soundPool, int sampleId, int status)
            {
                // success
                if (status == 0 && sfxPoolSessionId == sessionId)
                {
                    Sound sound = loadedSounds.get(sampleId);
                    // duration unknown
                    if (sound != null)
                    {
                        sound.onSoundReady(0);
                    }
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

    private synchronized void release()
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

    private synchronized boolean prepareSound(final Sound sound, final boolean shouldPlay)
    {
        // recreate sfxPool if needed, we're in a recoverable state
        if (sfxPool == null) {
            create();
        }

        String fileUrl = sound.getFileUrl();

        try
        {
            int soundId = -1;
            if (sound.isFromAssets())
            {
                AssetManager assets = assetManager.get();

                // if asset manager is null, we're in a VERY bad state
                if (assets == null)
                {
                    return false;
                }

                AssetFileDescriptor afd = assets.openFd(fileUrl);

                // load the file always with the same priority
                soundId = sfxPool.load(afd, 1);

                afd.close();
            }
            else
            {
                soundId = sfxPool.load(fileUrl, 1);
            }

            sound.setId(soundId);
            if (soundId != -1)
            {
                loadedSounds.put(soundId, sound);
            }
        }
        catch (IOException e)
        {
            Log.e(TAG, "" + e.getMessage());
            return false;
        }

        return true;
    }

    public void playSound(Sound sound)
    {
        // recreate sfxPool if needed, we're in a recoverable state
        if (sfxPool == null) {
            create();
        }

        if (sound.isReady())
        {
            Log.d(TAG, "Playing sound: " + sound.getId());

            // -1 means loop forever
            int stream = sfxPool.play(sound.getId(), sound.getVolume(), sound.getVolume(), 1, sound.getLoopCount(), 1.0f);

            // if the stream is more than 0, it succeeded
            if (stream > 0)
            {
                soundStreams.put(stream, sound.getId());

                // stream is not paused
                soundStreamsPaused.put(stream, false);
            }
        }
    }

    public void stopSound(Sound sound)
    {
        Log.d(TAG, "Stopping sound: " + sound.getId());

        if (sfxPool != null) {
            int[] streams = findSoundInStreams(sound.getId());

            for (int stream : streams)
            {
                if (stream > 0)
                {
                    sfxPool.stop(stream);
                    // no point in deleting the stream, just set the sound with an invalid ID
                    soundStreams.put(stream, -1);
                    // stream is not paused
                    soundStreamsPaused.put(stream, false);
                }
            }
        }
    }

    public void pauseSound(Sound sound)
    {
        if (sfxPool != null)
        {
            int[] streams = findSoundInStreams(sound.getId());

            for (int stream : streams)
            {
                if (stream > 0)
                {
                    sfxPool.pause(stream);
                    // stream is now paused, don't update the soundStreams array
                    soundStreamsPaused.put(stream, true);
                }
            }
        }
    }

    public void resumeSound(Sound sound)
    {
        if (sfxPool != null) {
            int[] streams = findSoundInStreams(sound.getId());

            for (int stream : streams)
            {
                if (stream > 0 && soundStreamsPaused.get(stream, false))
                {
                    // if the sound was found and the stream corresponding to the sound is paused, resume it
                    sfxPool.resume(stream);
                    // update the stream state back to unpaused (playing)
                    soundStreamsPaused.put(stream, false);
                }
            }
        }
    }

    public void setSoundVolume(Sound sound, float volume)
    {
        if (sfxPool != null)
        {
            int[] streams = findSoundInStreams(sound.getId());

            for (int stream : streams)
            {
                if (stream > 0)
                {
                    sfxPool.setVolume(stream, volume, volume);
                }
            }
        }
    }

    private int[] findSoundInStreams(int soundId)
    {
        int[] streams = new int[soundStreams.size()];

        for (int index = 0; index != soundStreams.size(); index++)
        {
            int currentStream = soundStreams.keyAt(index);
            int currentSoundInStream = soundStreams.get(currentStream);

            if (currentSoundInStream == soundId)
            {
                // the sound is currently playing in this stream
                streams[index] = currentStream;
            }
        }

        return streams;
    }


    //
    // Player settings (TODO later)
    //

    //
    // State handling
    //

    public synchronized boolean initializeMusic(final Music music)
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
        }

        reset();

        String fileUrl = music.getFileUrl();

        // we're using the AssetManager, so we are automatically inside the path
        if (fileUrl.startsWith("assets/"))
        {
            fileUrl = fileUrl.substring(7);
        }

        try
        {
            // load the file and set it as a data source in the player
            AssetFileDescriptor afd = assets.openFd(fileUrl);
            player.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getDeclaredLength());
            playerState = MediaPlayerState.INITIALIZED;
            afd.close();

            replaceMusic(music);

            prepareMusic(music, false);
        }
        catch (IOException e)
        {
            Log.e(TAG, "" + e.getMessage());
            return false;
        }

        return true;
    }

    private void prepareMusic(final Music music, final boolean shouldPlay)
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
                        playMusic(music);
                    }
                    else
                    {
                        music.onSoundReady(getCurrentMusicDuration());
                    }
                }
            });

            // prepare the sound
            playerState = MediaPlayerState.PREPARING;
            player.prepareAsync();
        }
    }

    public void playMusic(final Music music)
    {
        if (playerState == MediaPlayerState.STARTED)
        {
            return;
        }

        FocusManager.request(this);

        // recreate player if needed, we're in a recoverable state
        if (player == null)
        {
            create();
        }

        if (playerState == MediaPlayerState.IDLE || lastMusic != music)
        {
            // we are changing songs, if it is playing, stop the current song
            if (player.isPlaying())
            {
                stopMusic();
            }

            // player is in an idle state, so we reset before initializing a sound
            reset();
            initializeMusic(music);
            return;
        }

        if (!isAbleToPlayMusic())
        {
            // if the current state means that we are not able to play (but not idle, then move it to stop and to
            // prepare, to be played when possible
            stopMusic();
            prepareMusic(music, true);
            return;
        }

        playerState = MediaPlayerState.STARTED;

        setMusicLoop(music.isLooped());
        setMusicVolume(music.getVolume());
        player.start();

        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                playerState = MediaPlayerState.PLAYBACK_COMPLETED;

                music.onSoundComplete();

                FocusManager.release(SoundManager.this);
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

    private void replaceMusic(final Music music)
    {
        if (lastMusic != null)
        {
            lastMusic.unload();
        }

        lastMusic = music;
    }

    private boolean isAbleToPlayMusic()
    {
        return playerState == MediaPlayerState.PREPARED || playerState == MediaPlayerState.STARTED ||
                playerState == MediaPlayerState.PAUSED || playerState == MediaPlayerState.PLAYBACK_COMPLETED;
    }

    public void requestFocus()
    {
        FocusManager.request(this);
    }
}
