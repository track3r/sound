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

import cpp.Lib;

private enum SoundState
{
    STOPPED;
    PLAYING;
    PAUSED;
}

class Sound
{
    public var volume(default, set): Float;
    public var loop(default, default): Bool;
    public var loadCallback: sound.Sound -> Void;
    public var fileUrl: String;

    ///Native function references
    private static var initializeNativeFunc = Lib.load("soundios","soundios_initialize",2);
    private static var playNativeFunc = Lib.load("soundios","soundios_play",3);
    private static var stopNativeFunc = Lib.load("soundios","soundios_stop",1);
    private static var pauseNativeFunc = Lib.load("soundios","soundios_pause",2);
    private static var setVolumeNativeFunc = Lib.load("soundios","soundios_setVolume",2);
    private static var setMuteNativeFunc = Lib.load("soundios","soundios_setMute",2);

    private var nativeSoundHandle: Dynamic;
    private var nativeSoundChannel: Dynamic;
    private var state: SoundState;

    private function new()
    {
        loop = false;
        volume = 1.0;

        state = SoundState.STOPPED;
    }

    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var pos: Int = 0;
        while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
        {
            pos++;
        }
        fileUrl = fileUrl.substr(pos);

        var soundObj: Sound = new Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;

        soundObj.loadSoundFile();
    }

    private function loadSoundFile(): Void
    {
        initializeNativeFunc(fileUrl, onSoundLoadedCallback);
    }

    private function onSoundLoadedCallback(nativeSoundHandle: Dynamic, length: Float): Void
    {
        this.nativeSoundHandle = nativeSoundHandle;

        if (loadCallback != null)
        {
            loadCallback(this);
        }
    }

    public function play(): Void
    {
        if (nativeSoundHandle != null)
        {
            if (state == SoundState.PAUSED && nativeSoundChannel != null)
            {
                pauseNativeFunc(nativeSoundChannel, false);
            }
            else
            {
                if (state != SoundState.STOPPED)
                {
                    stop();
                }

                nativeSoundChannel = playNativeFunc(nativeSoundHandle, volume, loop);

                if (!nativeSoundChannel)
                {
                    setVolumeNativeFunc(nativeSoundChannel, volume);
                }
            }
            state = SoundState.PLAYING;
        }
    }

    public function stop(): Void
    {
        if (state != SoundState.STOPPED && nativeSoundChannel != null)
        {
            stopNativeFunc(nativeSoundChannel);
            nativeSoundChannel = null;
            state = SoundState.STOPPED;
        }
    }

    public function pause(): Void
    {
        if (state == SoundState.PLAYING && nativeSoundChannel != null)
        {
            pauseNativeFunc(nativeSoundChannel,true);
            state = SoundState.PAUSED;
        }
    }

    public function mute(): Void
    {
        if (nativeSoundChannel != null)
        {
            setMuteNativeFunc(nativeSoundChannel, true);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        if (nativeSoundChannel != null)
        {
            setVolumeNativeFunc(nativeSoundChannel, volume);
        }
        return volume;
    }

}
