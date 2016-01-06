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
    private FocusManager()
    {
        // can't be instantiated
    }

    public static void request(final AudioManager.OnAudioFocusChangeListener listener)
    {
        // if music is not playing don't request the global focus
        if (!isMusicPlaying())
        {
            return;
        }

        DuellActivity activity = DuellActivity.getInstance();

        if (activity != null)
        {
            AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
            audioManager.requestAudioFocus(listener, AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN);
        }
    }

    public static void release(final AudioManager.OnAudioFocusChangeListener listener)
    {
        DuellActivity activity = DuellActivity.getInstance();

        if (activity != null)
        {
            AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
            audioManager.abandonAudioFocus(listener);
        }
    }

    public static boolean isMusicPlaying()
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
