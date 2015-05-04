/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import msignal.Signal;
import types.Data;
import cpp.Lib;
///=================///
/// Sound IOS       ///
///                 ///
///=================///
class Sound
{
    public var volume(default, set_volume): Float;
    public var loop(default, set_loop): Int;
    public var length(get_length, null): Float;
    public var position(get_position, null): Float;
    public var loadCallback: sound.Sound -> Void;
    public var fileUrl: String;
    public var nativeSoundHandle: Dynamic;
    public var nativeSoundChannel: Dynamic;
    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","soundios_registerCallback",1);
    private static var initializeNativeFunc = Lib.load("soundios","soundios_initialize",2);
    private static var playNativeFunc = Lib.load("soundios","soundios_play",1);
    private static var stopNativeFunc = Lib.load("soundios","soundios_stop",1);
    private static var pauseNativeFunc = Lib.load("soundios","soundios_pause",2);
    private static var setLoopNativeFunc = Lib.load("soundios","soundios_setLoop",2);
    private static var setVolumeNativeFunc = Lib.load("soundios","soundios_setVolume",2);
    private static var setMuteNativeFunc = Lib.load("soundios","soundios_setMute",2);

    public var onPlaybackComplete(default,null): Signal1<Sound>;

    private function new()
    {
        loop = 0;
    }
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var soundObj: Sound = new Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;

        var pos: Int = 0;
        while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
        {
            pos++;
        }

        fileUrl = fileUrl.substr(pos);

        soundObj.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        registerCallbackNativeFunc(onSoundLoadedCallback);
        initializeNativeFunc(fileUrl,this);
    }
    private function onSoundLoadedCallback(nativeSoundHandle: Dynamic): Void
    {
        this.nativeSoundHandle = nativeSoundHandle;
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        if(nativeSoundHandle != null)
        {
            nativeSoundChannel = playNativeFunc(nativeSoundHandle);
        }
    }

    public function stop(): Void
    {
        if(nativeSoundChannel != null)
        {
            stopNativeFunc(nativeSoundChannel);
        }
    }

    public function pause(): Void
    {
        if(nativeSoundChannel != null)
        {
            pauseNativeFunc(nativeSoundChannel,true);
        }
    }

    public function mute(): Void
    {
        if(nativeSoundChannel != null)
        {
            setMuteNativeFunc(nativeSoundChannel, true);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        if(nativeSoundChannel != null)
        {
            setVolumeNativeFunc(nativeSoundChannel, volume);
        }
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Int): Int
    {
        loop = value;
        if(nativeSoundChannel != null)
        {
            setLoopNativeFunc(nativeSoundChannel, loop);
        }
        return loop;
    }

    /// get the length of the current sound
    private function get_length(): Float
    {
        return 0.0;
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        return 0.0;
    }
}
