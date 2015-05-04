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
class Music
{
    public var volume(default, set_volume): Float;
    public var loop(default, set_loop): Int;
    public var length(get_length, null): Float;
    public var position(get_position, null): Float;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;
    public var nativeSoundHandle: Dynamic;
    public var nativeSoundChannel: Dynamic;
    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","musicios_registerCallback",1);
    private static var initializeNativeFunc = Lib.load("soundios","musicios_initialize",1);
    private static var playNativeFunc = Lib.load("soundios","musicios_play",2);
    private static var stopNativeFunc = Lib.load("soundios","musicios_stop",0);
    private static var pauseNativeFunc = Lib.load("soundios","musicios_pause",1);
    private static var setLoopNativeFunc = Lib.load("soundios","musicios_setLoop",1);
    private static var setVolumeNativeFunc = Lib.load("soundios","musicios_setVolume",1);
    private static var setMuteNativeFunc = Lib.load("soundios","musicios_setMute",1);

    public var onPlaybackComplete(default,null): Signal1<Music>;

    private function new()
    {
        loop = 0;
    }
    public static function load(fileUrl: String,loadCallback: sound.Music -> Void): Void
    {
        var music: Music = new Music();
        music.loadCallback = loadCallback;
        music.fileUrl = fileUrl;

        var pos: Int = 0;
        while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
        {
            pos++;
        }

        fileUrl = fileUrl.substr(pos);

        music.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        registerCallbackNativeFunc(onSoundLoadedCallback);
        initializeNativeFunc(fileUrl);
    }
    private function onSoundLoadedCallback(): Void
    {
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        playNativeFunc(fileUrl, loop);
    }

    public function stop(): Void
    {
        stopNativeFunc();
    }

    public function pause(): Void
    {
        pauseNativeFunc(true);
    }

    public function mute(): Void
    {
        setMuteNativeFunc(true);
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        setVolumeNativeFunc(volume);
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    private function set_loop(value: Int): Int
    {
        loop = value;
        setLoopNativeFunc(loop);
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
