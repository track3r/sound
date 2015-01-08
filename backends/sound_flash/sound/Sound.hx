/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import filesystem.FileSystem;
import msignal.Signal;
import types.Data;
import flash.media.Sound;
import flash.media.SoundChannel;

import filesystem.FileSystem;

///=================///
/// Sound flash     ///
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

    private var fileData: Data = null;
    private var flashSound: flash.media.Sound;
    private var flashSoundChannel: SoundChannel;
    private function new()
    {
        
    }

    @:access(filesystem.FileSystem)
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var fileData = FileSystem.instance().getData(fileUrl);

        if (fileData == null)
            throw "sound does not exist: " + fileUrl;

        var sound: Sound = new Sound();
        sound.loadCallback = loadCallback;
        sound.fileUrl = fileUrl;
        sound.fileData = fileData;
        sound.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        flashSound = new flash.media.Sound();
        /*
        flashSound.addEventListener(flash.events.Event.COMPLETE, function(event: flash.events.Event)
        {
            if(this.loadCallback != null)
            {
                this.loadCallback(this);
            }
        });

        flashSound.load(new flash.net.URLRequest(fileUrl));
        */
        flashSound.loadCompressedDataFromByteArray(fileData.byteArray, fileData.byteArray.length);

        if (this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }

    public function play(): Void
    {
        flashSoundChannel = flashSound.play();
    }

    public function stop(): Void
    {
        if(flashSoundChannel != null)
        {
            flashSoundChannel.stop();
            flashSoundChannel = null;
        }
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
