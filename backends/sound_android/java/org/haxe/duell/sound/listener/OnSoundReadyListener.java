/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.sound.listener;

import org.haxe.duell.sound.Sound;

/**
 * @author jxav
 */
public interface OnSoundReadyListener
{
    void onSoundReady(Sound sound, int soundId, long soundDurationMillis);
}
