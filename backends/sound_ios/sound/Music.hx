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

package sound;

import msignal.Signal;
import cpp.Lib;

using StringTools;

private enum MusicState
{
    STOPPED;
    PLAYING;
    PAUSED;
}

class Music
{
    public var volume(default, set): Float;
    public var loop(default, default): Bool;
    public var length(get, null): Float;
    public var position(get, null): Float;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;
    public var onPlaybackComplete(default, null): Signal1<Music>;

    public static var allowNativePlayer(default, set_allowNativePlayer): Bool = true;

    ///Native function references
    private static var initializeNativeFunc = Lib.load("soundios","musicios_initialize",2);
    private static var playNativeFunc = Lib.load("soundios","musicios_play",3);
    private static var stopNativeFunc = Lib.load("soundios","musicios_stop",1);
    private static var pauseNativeFunc = Lib.load("soundios","musicios_pause",2);
    private static var setVolumeNativeFunc = Lib.load("soundios","musicios_setVolume",2);
    private static var setMuteNativeFunc = Lib.load("soundios","musicios_setMute",2);
    private static var setAllowNativePlayerNativeFunc = Lib.load("soundios","musicios_setAllowNativePlayer",1);
    private static var getIsOtherAudioPlaying = Lib.load("soundios","musicios_isOtherAudioPlaying",0);
    private static var getLengthNative = Lib.load("soundios","musicios_getLength",1);
    private static var getPositionNative = Lib.load("soundios","musicios_getPosition",1);
    private static var appDelegateInitialize = Lib.load("soundios","musicios_appdelegate_initialize",0);
    private static var appDelegateSetForgraundCallback = Lib.load("soundios","musicios_appdelegate_set_willEnterForegroundCallback",1);
    private static var appDelegateSetBackgroundCallback = Lib.load("soundios","musicios_appdelegate_set_willEnterBackgroundCallback",1);

    private static var instances: Array<Music> = [];
    private static var addDelegateInitialized: Bool = false;

    private var nativeMusicChannel: Dynamic;
    private var state: MusicState;

    private function new()
    {
        loop = false;
        volume = 1.0;
        state = MusicState.STOPPED;
        onPlaybackComplete = new Signal1();
    }

    public static function load(fileUrl: String, loadCallback: Music -> Void): Void
    {
        var music: Music = new Music();
        instances.push(music);

        music.loadCallback = loadCallback;

        /// Workaround the OALTools path resolving bug
        music.fileUrl = fileUrl.substr("file://".length);

        music.loadSoundFile();
    }

    private function loadSoundFile(): Void
    {
        if (!addDelegateInitialized)
        {
            addDelegateInitialized = true;
            appDelegateInitialize();
            appDelegateSetBackgroundCallback(onBackground);
            //appDelegateSetForgraundCallback(onForeground);
        }

        nativeMusicChannel = initializeNativeFunc(fileUrl, onMusicFinishPlayingCallback);

        if (loadCallback != null)
        {
            loadCallback(this);
        }
    }

    // Hack XYZ: in order to prevent both the native and game music to play at the same time for 1 second, save the current
    // volume and music the sound.
    // TODO: try to prevent the game music from auto resuming when the apps goes to the foreground.
    var onBackgroundMusicVolume: Float = 0.0;
    // end of hack XYZ

    private static function onBackground(): Void
    {
        for (i in 0...instances.length)
        {
            var music = instances[i];

            // Hack XYZ:
            var volume = music.volume;
            music.volume = 0.0;
            music.onBackgroundMusicVolume = volume;
            // end of hack XYZ
        }
    }

    private static function onForeground(): Void
    {
        // keep this for now, useful for debuging.
    }

    private function onMusicFinishPlayingCallback(): Void
    {
        state = MusicState.STOPPED;
        onPlaybackComplete.dispatch(this);
    }

    public function play(): Void
    {
        if (allowNativePlayer && isNativePlayerPlaying())
        {
            stop();
            return;
        }

        // Hack XYZ: restore the volume
        if (onBackgroundMusicVolume != 0.0)
        {
            volume = onBackgroundMusicVolume;
        }
        // end of hack XYZ

        if (nativeMusicChannel != null)
        {
            if (state == MusicState.PAUSED)
            {
                /// if it is paused we just resume
                pauseNativeFunc(nativeMusicChannel, false);
            }
            else
            {
                /// otherwise we play normally
                playNativeFunc(nativeMusicChannel, volume, loop);
            }
            state = MusicState.PLAYING;
        }
    }

    public function stop(): Void
    {
        if (state != MusicState.STOPPED && nativeMusicChannel != null)
        {
            stopNativeFunc(nativeMusicChannel);
            state = MusicState.STOPPED;
            onPlaybackComplete.dispatch(this);
        }
    }

    public function pause(): Void
    {
        if (state == MusicState.PLAYING && nativeMusicChannel != null)
        {
            pauseNativeFunc(nativeMusicChannel, true);
            state = MusicState.PAUSED;
        }
    }

    public function mute(): Void
    {
        if (nativeMusicChannel != null)
        {
            setMuteNativeFunc(nativeMusicChannel, true);
        }
    }

    public static function isNativePlayerPlaying(): Bool
    {
        return getIsOtherAudioPlaying();
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        onBackgroundMusicVolume = 0.0;

        if (nativeMusicChannel != null)
        {
            setVolumeNativeFunc(nativeMusicChannel, volume);
        }
        return volume;
    }

    private static function set_allowNativePlayer(value: Bool): Bool
    {
        if (allowNativePlayer != value)
        {
            allowNativePlayer = value;
            setAllowNativePlayerNativeFunc(allowNativePlayer);
        }

        return allowNativePlayer;
    }

    /// get the length of the current sound
    private function get_length(): Float
    {
        return (nativeMusicChannel != null) ? getLengthNative(nativeMusicChannel) : 0.0;
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        return (nativeMusicChannel != null) ? getPositionNative(nativeMusicChannel) : 0.0;
    }
}
