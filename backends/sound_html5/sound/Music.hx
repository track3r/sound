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
import msignal.Signal.Signal1;

import js.html.Blob;
import js.html.URL;

import howler.Howl;

class Music
{
    public var volume(default,set): Float = 1.0;
    public var loop(default,set): Bool = false;
    public var length(get,null): Float;
    public var position(get,null): Float;
    public var loadCallback: sound.Music -> Void;
    public var onPlaybackComplete(default,null): Signal1<Music> = new Signal1();

    private var paused: Bool = false;
    private var soundId: String;
    private var howl: Howl;

    /// useless on this target
    public static var allowNativePlayer(default, default): Bool;

    public static function load(url: String,loadCallback: sound.Music -> Void): Void
    {
        new Music(url, loadCallback);
    }

    private function new(url: String, loadCallback: Music->Void)
    {
        var data = FileSystem.instance().getData(url);

        if (data != null)
        {
            howl = new Howl({
                urls: [URL.createObjectURL(new Blob([data.arrayBuffer]))],
                format: "mp3",
                onload: function() {
                    loadCallback(this);
                },
                onloaderror: function(error: String)
                {
                    howl = null;
                    trace('ERROR loading music URL=${url} ($error).');
                },
                onend: function(id: String) {
                    if (howl == null)
                        return;

                    if (!howl.loop())
                    {
                        soundId = null;
                        if (onPlaybackComplete != null)
                        {
                            onPlaybackComplete.dispatch(this);
                        }
                    }
                }
            });
        }
        else
        {
            trace('ERROR loading music URL=${url}. Sounds are not supported outside the assets.');
            loadCallback(this);
        }
    }

    public function play(): Void
    {
        if (howl == null)
            return;

        if (paused && soundId != null)
        {
            howl.play(null, soundId);
            paused = false;
            return;
        }

        if (soundId != null)
        {
            howl.stop(soundId);
            soundId = null;
        }

        howl.play(function(id: String) {
            soundId = id;
        });
    }

    public function stop(): Void
    {
        if (howl == null)
            return;

        if (soundId != null)
        {
            howl.stop(soundId);
            soundId = null;
            if (onPlaybackComplete != null)
            {
                onPlaybackComplete.dispatch(this);
            }
        }
        paused = false;
    }

    public function pause(): Void
    {
        if (howl != null && soundId != null)
        {
            paused = true;
            howl.pause(soundId);
        }
    }

    public function mute(): Void
    {
        if (howl != null && soundId != null)
        {
            howl.mute(soundId);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        if (howl != null)
        {
            howl.volume(value);
        }
        volume = value;
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Bool): Bool
    {
        if (howl != null)
        {
            howl.loop(value);
        }
        loop = value;
        return loop;
    }

    /// get the length of the current sound
    private function get_length(): Float
    {
        if (howl == null || soundId == null)
        {
            return 0.0;
        }
        return howl.duration();
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        if (howl == null || soundId == null)
        {
            return 0.0;
        }
        return howl.pos(null, soundId) % length;
    }
}
