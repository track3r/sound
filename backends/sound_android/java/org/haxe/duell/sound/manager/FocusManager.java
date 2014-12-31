/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.sound.manager;

import android.annotation.TargetApi;
import android.content.Context;
import android.media.AudioManager;
import android.os.Build;
import org.haxe.duell.DuellActivity;

/**
 * @author jxav
 */
@TargetApi(Build.VERSION_CODES.FROYO)
public final class FocusManager
{
    private static boolean globalFocusRequested = false;

    private FocusManager()
    {
        // can't be instantiated
    }

    public static void request(final AudioManager.OnAudioFocusChangeListener listener)
    {
        // if music is not playing don't request the global focus
        if (isMusicPlaying())
        {
            globalFocusRequested = false;
            return;
        }

        DuellActivity activity = DuellActivity.getInstance();

        if (activity != null)
        {
            AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
            audioManager.requestAudioFocus(listener, AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN);
            globalFocusRequested = true;
        }
    }

    public static void requestTemporary(final AudioManager.OnAudioFocusChangeListener listener)
    {
        DuellActivity activity = DuellActivity.getInstance();

        if (activity != null)
        {
            AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
            audioManager.requestAudioFocus(listener, AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK);
        }
    }

    public static void release(final AudioManager.OnAudioFocusChangeListener listener)
    {
        DuellActivity activity = DuellActivity.getInstance();

        if (activity != null)
        {
            AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
            audioManager.abandonAudioFocus(listener);
            globalFocusRequested = false;
        }
    }

    public static void onSoundComplete(final AudioManager.OnAudioFocusChangeListener listener)
    {
        // release temporary focus, since we just wanted to acquire it briefly
        if (!globalFocusRequested)
        {
            release(listener);
        }
    }

    private static boolean isMusicPlaying()
    {
        DuellActivity activity = DuellActivity.getInstance();

        if (activity != null)
        {
            AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
            return audioManager.isMusicActive();
        }

        return false;
    }
}
