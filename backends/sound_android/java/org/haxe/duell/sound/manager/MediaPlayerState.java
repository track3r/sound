/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.sound.manager;

/**
 * @author jxav
 */
public enum MediaPlayerState
{
    IDLE,
    INITIALIZED,
    PREPARING,
    PREPARED,
    STARTED,
    PAUSED,
    PLAYBACK_COMPLETED,
    STOPPED,
    END,
    ERROR
}
