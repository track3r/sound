/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import msignal.Signal;
import createjs.soundjs.Sound;
import createjs.soundjs.WebAudioPlugin;
import createjs.soundjs.HTMLAudioPlugin;
import types.Data;
///=================///
/// Sound html5     ///
///                 ///
///=================///
class Sound
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var onPlaybackComplete(default,null): Signal1<Sound>;
    public var loadCallback: sound.Sound -> Void;
    public var fileUrl: String;

    public function new()
    {
        //fallback will be in the same order
        createjs.soundjs.Sound.registerPlugins([createjs.soundjs.WebAudioPlugin, createjs.soundjs.HTMLAudioPlugin]);
    }
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var sound: Sound = new Sound();
        sound.loadCallback = loadCallback;
        sound.fileUrl = fileUrl;
        sound.loadSoundFile();
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
        createjs.soundjs.Sound.play(fileUrl);
    }

    public function stop(): Void
    {
        createjs.soundjs.Sound.stop();
    }

    public function pause(): Void
    {
        //TODO: Impliment me
    }

    public function mute(): Void
    {
        //TODO: Impliment me
    }

    /// here you can do platform specific logic to set the sound volume
    public function set_volume(value: Float): Float
    {
        volume = value;
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    public function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
    }

    /// get the length of the current sound
    public function get_length(): Float
    {
        //TODO: Impliment me
        return 0.0;
    }

    /// get the current time of the current sound
    public function get_position(): Float
    {
        //TODO: Impliment me
        return 0.0;
    }
}
