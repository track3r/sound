/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import createjs.soundjs.Sound;
import createjs.soundjs.WebAudioPlugin;
import createjs.soundjs.HTMLAudioPlugin;

import filesystem.FileSystem;

import types.Data;
///=================///
/// Sound html5     ///
///                 ///
///=================///
class Sound
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Int;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var loadCallback: sound.Sound -> Void;

    public var fileUrl: String;
    private var soundInstance: createjs.soundjs.SoundInstance;
    private var isPaused: Bool;
    private static var pluginsRegistered: Bool = false; 

    private function new()
    {
        isPaused = false;
        loop = 0;
    }
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        if (fileUrl.indexOf(FileSystem.instance().urlToStaticData()) == 0)
        {
            fileUrl = fileUrl.substr(FileSystem.instance().urlToStaticData().length);

            var pos: Int = 0;
            while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
            {
                pos++;
            }
            fileUrl = fileUrl.substr(pos);

            fileUrl = "assets/" + fileUrl;
        }
        else if (fileUrl.indexOf(FileSystem.instance().urlToCachedData()) == 0 ||
                 fileUrl.indexOf(FileSystem.instance().urlToTempData()) == 0)
        {
            throw "Sounds not supported outside the assets";
        }

        if(!pluginsRegistered)
        {
            //fallback will be in the same order
            createjs.soundjs.Sound.registerPlugins([createjs.soundjs.WebAudioPlugin, createjs.soundjs.HTMLAudioPlugin]);
            pluginsRegistered = true;
        }

        var soundObj: Sound = new Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;
        soundObj.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        createjs.soundjs.Sound.addEventListener("fileload", handleLoad);
        createjs.soundjs.Sound.registerSound(fileUrl,fileUrl);
    }  
    private function handleLoad(event: Dynamic): Void
    {
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        if(soundInstance == null)
        {
            return;
        }
        if(isPaused)
        {
            soundInstance.resume();
            isPaused = false;
            return;
        }
        var loopsCount = 9999;
        if(loop == 0)
        {
            loopsCount = 0;
        }
        else if(loop > 0)
        {
            loopsCount = loop;
        }
        soundInstance = createjs.soundjs.Sound.play(fileUrl,null,0,loopsCount);
    }

    public function stop(): Void
    {
        if(soundInstance != null)
        {
            soundInstance.stop();
            soundInstance = null;
        }
    }

    public function pause(): Void
    {
        if(soundInstance != null)
        {
            isPaused = true;
            soundInstance.pause();
        }
    }

    public function mute(): Void
    {
        if(soundInstance != null)
        {
            soundInstance.setMute(true);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Int): Int
    {
        loop = value;
        return loop;
    }

    /// get the length of the current sound
    private function get_length(): Float
    {
        if(soundInstance == null)
        {
            return 0.0;
        }
        return soundInstance.getDuration();
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        if(soundInstance == null)
        {
            return 0.0;
        }
        return soundInstance.getPosition();
    }
}
