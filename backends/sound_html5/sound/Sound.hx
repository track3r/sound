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
    public var fileUrl: String;

    public var currentSoundIds: Array<String> = [];

    private var blob: Blob;
    private var howl: Howl;
    private var isPaused: Bool = false;

    private function new() {}

    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        if (fileUrl.indexOf(FileSystem.instance().getUrlToStaticData()) == -1 &&
            fileUrl.indexOf(FileSystem.instance().getUrlToTempData()) == -1)
        {
            trace('ERROR playing sound URL=${fileUrl}. Sounds not supported outside the assets.');
            loadCallback(null);
        }
        else
        {
            var soundObject = new Sound();
            soundObject.loadSoundFile(fileUrl, loadCallback);
        }
    }

    private function loadSoundFile(url: String, loadCallback: Sound->Void): Void
    {
        fileUrl = url;

        var data = FileSystem.instance().getData(fileUrl);

        blob = new Blob([data.arrayBuffer]);
        var blobUrl = URL.createObjectURL(blob, {type: "audio/mpeg"});

        howl = new Howl({
            urls: [blobUrl],
            format: "mp3",
            onload: function() {
                loadCallback(this);
            },
            onloaderror: function(error: String)
            {
                trace ("[Sound] error loading file with url " + fileUrl + "with error " + error);
            },
            onend: function(id: String) {
                if (howl == null)
                    return;

                if (!howl.loop())
                {
                    currentSoundIds.remove(id);
                }
            }
        });
    }

    public function play(): Void
    {
        if (howl == null)
            return;

        if (isPaused)
        {
            for (id in currentSoundIds)
            {
                howl.play(null, id);
            }

            isPaused = false;
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
        isPaused = false;
    }

    public function pause(): Void
    {
        for (id in currentSoundIds)
        {
            howl.pause(id);
        }

        isPaused = true;
    }

    public function mute(): Void
    {
        for (id in currentSoundIds)
        {
            howl.mute(id);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        howl.volume(value);
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        howl.loop(value);
        return loop;
    }
}
