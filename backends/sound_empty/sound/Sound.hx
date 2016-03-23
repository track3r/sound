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

import filesystem.FileSystem;

import types.Data;

enum SoundState
{
    STOPPED;
    PLAYING;
    PAUSED;
}

class Sound
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var loadCallback: sound.Sound -> Void;
    public var fileUrl: String;

    private function new()
    {
        loop = false;
        volume = 1;
    }

    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var soundObj: sound.Sound = new sound.Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;
        soundObj.loadSoundFile();
    }

    public function loadSoundFile(): Void
    {
        if (this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }

    public function play(): Void
    {
    }

    public function stop(): Void
    {
    }

    public function pause(): Void
    {
    }

    /**
    * Mute sound
    */
    public function mute(): Void
    {
        volume = 0;
    }

    /**
    * Disposes the current sound and sound channel
    */
    public function dispose():Void
    {
    }

    /**
    * Set the current sound volume
    * @param value Float range 0..1
    */
    private function set_volume(value: Float): Float
    {
        volume = value;
        return volume;
    }

    /**
    * If set to true the sound will loop as long as
    * stop() or pause is called
    */
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
    }

    /**
    * Get the current sound length (in milliseconds)
    */
    private function get_length(): Float
    {
        return 0.0;
    }

    /**
    * Get the current sound delayed time (in milliseconds)
    */
    private function get_position(): Float
    {
        return 0.0;
    }
}
