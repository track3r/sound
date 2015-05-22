/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package test;

import sound.Sound;
import sound.Music;

import unittest.TestCase;
/**
 * @author kgar
 */
class SoundTest extends TestCase
{
    private var SOUND_URL: String = "shotgun.mp3";
    private var MUSIC_URL: String = "helicopter.mp3";

    public function testIfSoundSuccessfullyLoaded(): Void
    {
        /// sound Callback
        function onSoundReady(loadedSound: Sound): Void
        {
            assertTrue(loadedSound != null);
            assertAsyncFinish("testIfSoundSuccessfullyLoaded");
        }
        assertAsyncStart("testIfSoundSuccessfullyLoaded", 3.0);
        Sound.load(SOUND_URL, onSoundReady);
    }

    public function testIfMusicSuccessfullyLoaded(): Void
    {
        /// music Callback
        function onMusicReady(loadedMusic: Music): Void
        {
            assertTrue(loadedSound != null);
            assertAsyncFinish("testIfMusicSuccessfullyLoaded");
        }
        assertAsyncStart("testIfMusicSuccessfullyLoaded", 3.0);
        Music.load(MUSIC_URL, onMusicReady);
    }

}
