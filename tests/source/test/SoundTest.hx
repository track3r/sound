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

package test;

import sound.Sound;
import sound.Music;

import unittest.TestCase;

import filesystem.FileSystem;

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
