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

    private var nativeSound: Dynamic;
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
        IOSSound.getInstance().preloadSFX(fileUrl);

        if (loadCallback != null)
        {
            loadCallback(this);
        }
    }

    public function play(): Void
    {
        if (state == SoundState.PAUSED && nativeSound != null)
        {
            IOSSound.getInstance().setSFXPause(nativeSound, false);
        }
        else
        {
            if (state != SoundState.STOPPED)
            {
                stop();
            }

            nativeSound = IOSSound.getInstance().playSFX(fileUrl, volume, loop);
        }
        state = SoundState.PLAYING;
    }

    public function stop(): Void
    {
        if (state != SoundState.STOPPED && nativeSound != null)
        {
            IOSSound.getInstance().stopSFX(nativeSound);
            state = SoundState.STOPPED;
        }
    }

    public function pause(): Void
    {
        if (state == SoundState.PLAYING && nativeSound != null)
        {
            IOSSound.getInstance().setSFXPause(nativeSound, true);
            state = SoundState.PAUSED;
        }
    }

    public function mute(): Void
    {
        if (nativeSound != null)
        {
            IOSSound.getInstance().setSFXMute(nativeSound, true);
        }
    }

    private function set_volume(value: Float): Float
    {
        volume = value;
        if (nativeSound != null)
        {
            IOSSound.getInstance().setSFXVolume(nativeSound, volume);
        }
        return volume;
    }

}
