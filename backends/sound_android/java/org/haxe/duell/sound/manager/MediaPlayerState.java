package org.haxe.duell.sound.manager;

/**
 * @author jxav
 * Copyright (c) 2014 GameDuell GmbH
 */
public enum MediaPlayerState {
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
