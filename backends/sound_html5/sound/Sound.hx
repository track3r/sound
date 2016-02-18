/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
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
