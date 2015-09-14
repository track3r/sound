/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package test;

import sound.Sound;
import sound.Music;

import unittest.TestCase;

import filesystem.FileSystem;
/**
 * @author kgar
 */
class SoundTest extends TestCase
{
    private var SOUND_URL: String = "shotgun.mp3";
    private var MUSIC_URL: String = "helicopter.mp3";

    public function testIfSoundSuccessfullyLoaded(): Void
    {
        var fileUrl: String = FileSystem.instance().getUrlToStaticData() + "/" + SOUND_URL;
        /// sound Callback
        function onSoundReady(loadedSound: Sound): Void
        {
            assertTrue(loadedSound != null);
            assertAsyncFinish("testIfSoundSuccessfullyLoaded");
        }
        assertAsyncStart("testIfSoundSuccessfullyLoaded", 3.0);
        Sound.load(fileUrl, onSoundReady);
    }

    public function testIfMusicSuccessfullyLoaded(): Void
    {
        var fileUrl: String = FileSystem.instance().getUrlToStaticData() + "/" + MUSIC_URL;
        /// music Callback
        function onMusicReady(loadedMusic: Music): Void
        {
            assertTrue(loadedMusic != null);
            assertAsyncFinish("testIfMusicSuccessfullyLoaded");
        }
        assertAsyncStart("testIfMusicSuccessfullyLoaded", 3.0);
        Music.load(fileUrl, onMusicReady);
    }

    public function testMoreThanOneSoundFxPlayingInstantlyWithoutCrash(): Void
    {
        var fileUrl: String = FileSystem.instance().getUrlToStaticData() + "/" + SOUND_URL;
        var sounds: Array<Sound> = [];
        function playSounds(): Void
        {
            for ( soundItem in sounds )
            {
                soundItem.loop = false;
                soundItem.volume = 0.5;
                soundItem.play();
            }
            assertAsyncFinish("testMoreThanOneSoundFxPlayingInstantlyWithoutCrash");
        }
        assertAsyncStart("testMoreThanOneSoundFxPlayingInstantlyWithoutCrash", 30.0);
        var i: Int = 0;
        function loadSound(): Void
        {
            Sound.load(fileUrl, function(s: Sound): Void
                                {
                                    i++;
                                    sounds.push(s);
                                    if(sounds.length == 5)
                                    {
                                        trace("Playing Sounds");
                                        playSounds();
                                    }
                                    else
                                    {
                                        loadSound();
                                    }
                                });
        }
        loadSound();
    }


}
