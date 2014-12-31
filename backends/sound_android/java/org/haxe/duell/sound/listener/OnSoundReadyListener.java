package org.haxe.duell.sound.listener;

import org.haxe.duell.sound.Sound;

/**
 * @author jxav
 * Copyright (c) 2014 GameDuell GmbH
 */
public interface OnSoundReadyListener
{
    void onSoundReady(Sound sound, long soundDurationMillis);
}
