/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;
import filesystem.FileSystem;
import msignal.Signal.Signal1;
/**
 * @author kgar
 */
class Music
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var onPlaybackComplete(default,null): Signal1<Music>;
    public var loadCallback: sound.Music -> Void;

    public var fileUrl: String;
    private var musicInstance: createjs.soundjs.SoundInstance;
    private var isPaused: Bool;
    private static var pluginsRegistered: Bool = false;

    public function new()
    {
        isPaused = false;
        loop = false;
        volume = 1.0;
    }

    public static function load(fileUrl: String,loadCallback: sound.Music -> Void): Void
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
        var music: Music = new Music();
        music.loadCallback = loadCallback;
        music.fileUrl = fileUrl;
        music.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        SoundLoader.getInstance().soundLoaded.add(soundHandleLoad);
        SoundLoader.getInstance().loadSound(fileUrl);
    }
    private function soundHandleLoad(soundID: String): Void
    {
        if(soundID == this.fileUrl)
        {
            if(this.loadCallback != null)
            {
                this.loadCallback(this);
            }
        }
    }
    public function play(): Void
    {
        if(isPaused && musicInstance != null)
        {
            musicInstance.resume();
            isPaused = false;
            return;
        }
        var loopsCount = 9999;
        if(!loop)
        {
            loopsCount = 0;
        }
        musicInstance = createjs.soundjs.Sound.play(fileUrl,null,0,loopsCount);
        musicInstance.on("complete", this.handlePlayComplete, this);
        musicInstance.volume = volume;
    }

    private function handlePlayComplete(): Void
    {
        if(onPlaybackComplete != null)
        {
            onPlaybackComplete.dispatch(this);
        }
    }
    public function stop(): Void
    {
        if(musicInstance != null)
        {
            musicInstance.stop();
            musicInstance = null;
        }
    }

    public function pause(): Void
    {
        if(musicInstance != null)
        {
            isPaused = true;
            musicInstance.pause();
        }
    }

    public function mute(): Void
    {
        if(musicInstance != null)
        {
            musicInstance.setMute(true);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        if(musicInstance != null)
        {
            musicInstance.volume = volume;
        }
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
    }

    /// get the length of the current sound
    private function get_length(): Float
    {
        if(musicInstance == null)
        {
            return 0.0;
        }
        return musicInstance.getDuration();
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        if(musicInstance == null)
        {
            return 0.0;
        }
        return musicInstance.getPosition();
    }
}
