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
import types.Data;
import cpp.Lib;
using StringTools;

class Music
{
    public var volume(default, set): Float;
    public var loop(default, set): Bool;
    public var length(get, null): Float;
    public var position(get, null): Float;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;
    public var onPlaybackComplete(default,null): Signal1<Music>;

    public static var allowNativePlayer(default, set_allowNativePlayer): Bool = true;

    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","musicios_registerCallback",2);
    private static var initializeNativeFunc = Lib.load("soundios","musicios_initialize",1);
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

    private var nativeMusicHandle: Dynamic;
    private var nativeMusicChannel: Dynamic;
    private var isPaused:Bool = false;

    private function new()
    {
        loop = false;
        volume = 1.0;
        onPlaybackComplete = new Signal1();
    }

    public static function load(fileUrl: String,loadCallback: sound.Music -> Void): Void
    {
        var music: Music = new Music();
        music.loadCallback = loadCallback;

        /// Workaround the OALTools path resolving bug
        music.fileUrl = fileUrl.substr("file://".length);

        music.loadSoundFile();
    }

    private function loadSoundFile(): Void
    {
        appDelegateInitialize();
        appDelegateSetBackgroundCallback(onBackground);
        appDelegateSetForgraundCallback(onForeground);

        registerCallbackNativeFunc(onSoundLoadedCallback, onMusicFinishPlayingCallback);
        nativeMusicChannel = initializeNativeFunc(fileUrl);
    }

    // Hack XYZ: in order to prevent both the native and game music to play at the same time for 1 second, save the current
    // volume and music the sound.
    // TODO: try to prevent the game music from auto resuming when the apps goes to the foreground.
    var onBackgroundMusicVolume: Float = 0.0;
    // end of hack XYZ

    private function onBackground(): Void
    {
        // Hack XYZ:
        onBackgroundMusicVolume = volume;
        volume = 0.0;
        // end of hack XYZ
    }

    private function onForeground(): Void
    {
        // keep this for now, useful for debuging.
    }

    private function onMusicFinishPlayingCallback(filePath: String): Void
    {
        if(filePath == fileUrl)
        {
            onPlaybackComplete.dispatch(this);
        }
    }
    private function onSoundLoadedCallback(nativeMusicHandle: Dynamic): Void
    {
        this.nativeMusicHandle = nativeMusicHandle;
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        if (allowNativePlayer && isNativePlayerPlaying())
        {
            stop();
            return;
        }

        // Hack XYZ: restore the volume
        if (onBackgroundMusicVolume != 0)
        {
            volume = onBackgroundMusicVolume;
            onBackgroundMusicVolume = 0;
        }
        // end of hack XYZ

        if(isPaused && nativeMusicChannel != null)
        {
            /// if it is paused we just resume
            isPaused = false;
            pauseNativeFunc(nativeMusicChannel, false);
        }
        else
        {
            /// otherwise we play normally
            playNativeFunc(fileUrl, volume, loop);
        }
    }

    public function stop(): Void
    {
        if(nativeMusicChannel != null)
        {
            stopNativeFunc(nativeMusicChannel);
            nativeMusicChannel = null;
        }
    }

    public function pause(): Void
    {
        if(nativeMusicChannel != null)
        {
            isPaused = true;
            pauseNativeFunc(nativeMusicChannel, true);
        }
    }

    public function mute(): Void
    {
        if(nativeMusicChannel != null)
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
        if(nativeMusicChannel != null)
        {
            setVolumeNativeFunc(nativeMusicChannel, volume);
        }
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
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
        if(nativeMusicChannel != null)
        {
            return getLengthNative(nativeMusicChannel);
        }
        return 0.0;
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        if(nativeMusicChannel != null)
        {
            return getPositionNative(nativeMusicChannel);
        }
        return 0.0;
    }
}
