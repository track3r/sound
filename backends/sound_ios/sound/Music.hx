/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import msignal.Signal;
import types.Data;
import cpp.Lib;
using StringTools;
///=================///
/// Sound IOS       ///
///                 ///
///=================///
class Music
{
    public var volume(default, set_volume): Float;
    public var loop(default, set_loop): Bool;
    public var length(get_length, null): Float;
    public var position(get_position, null): Float;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;
    public var nativeSoundHandle: Dynamic;
    public var nativeSoundChannel: Dynamic;
    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","musicios_registerCallback",2);
    private static var initializeNativeFunc = Lib.load("soundios","musicios_initialize",1);
    private static var playNativeFunc = Lib.load("soundios","musicios_play",2);
    private static var stopNativeFunc = Lib.load("soundios","musicios_stop",0);
    private static var pauseNativeFunc = Lib.load("soundios","musicios_pause",1);
    private static var setLoopNativeFunc = Lib.load("soundios","musicios_setLoop",1);
    private static var setVolumeNativeFunc = Lib.load("soundios","musicios_setVolume",1);
    private static var setMuteNativeFunc = Lib.load("soundios","musicios_setMute",1);
    private static var getLengthNative = Lib.load("soundios","musicios_getLength",0);
    private static var getPositionNative = Lib.load("soundios","musicios_getPosition",0);

    public var onPlaybackComplete(default,null): Signal1<Music>;

    private function new()
    {
        loop = false;
        onPlaybackComplete = new Signal1();
    }
    public static function load(fileUrl: String,loadCallback: sound.Music -> Void): Void
    {
        var music: Music = new Music();
        music.loadCallback = loadCallback;

        /// Workaround the OALTools path resolving bug
        music.fileUrl = fileUrl.substr("file://".length);

        music.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        registerCallbackNativeFunc(onSoundLoadedCallback, onMusicFinishPlayingCallback);
        initializeNativeFunc(fileUrl);
    }

    private function onMusicFinishPlayingCallback(): Void
    {
        onPlaybackComplete.dispatch(this);
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
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        setLoopNativeFunc(loop);
        return loop;
    }

    /// get the length of the current sound
    private function get_length(): Float
    {
        return getLengthNative();
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        return getPositionNative();
    }
}
