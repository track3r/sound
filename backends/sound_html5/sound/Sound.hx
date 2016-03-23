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

class Sound
{
    public var volume(default,set): Float = 1.0;
    public var loop(default,set): Bool = false;

    public var currentSoundIds: Array<String> = [];

    private var howl: Howl;
    private var paused: Bool = false;

    public static function load(url: String, loadCallback: sound.Sound -> Void): Void
    {
        new Sound(url, loadCallback);
    }

    private function new(url: String, loadCallback: Sound->Void)
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
                    trace('ERROR loading sound URL=${url} ($error).');
                },
                onend: function(id: String) {
                    if (howl != null && !howl.loop())
                    {
                        currentSoundIds.remove(id);
                    }
                }
            });
        }
        else
        {
            trace('ERROR loading sound URL=${url}. Sounds are not supported outside the assets.');
            loadCallback(this);
        }
    }

    public function play(): Void
    {
        if (howl == null)
            return;

        if (paused)
        {
            for (id in currentSoundIds)
            {
                howl.play(null, id);
            }

            paused = false;
        }
        else
        {
            howl.play(function(id: String) {
                currentSoundIds.push(id);
            });
        }
    }

    public function stop(): Void
    {
        if (howl == null)
            return;

        for (id in currentSoundIds)
        {
            howl.stop(id);
        }

        currentSoundIds = [];
        paused = false;
    }

    public function pause(): Void
    {
        if (howl == null || currentSoundIds.length == 0)
            return;

        for (id in currentSoundIds)
        {
            howl.pause(id);
        }

        paused = true;
    }

    public function mute(): Void
    {
        if (howl == null)
            return;

        for (id in currentSoundIds)
        {
            howl.mute(id);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        if (howl != null)
        {
            howl.volume(value);
        }
        return value;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        if (howl != null)
        {
            howl.loop(value);
        }
        return value;
    }
}
