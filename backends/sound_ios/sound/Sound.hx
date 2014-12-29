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
    public var loop(default, set_loop): Bool;
    public var length(get_length, null): Float;
    public var position(get_position, null): Float;


    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("iossound","iossound_registerCallback",1);
    private static var initializeNativeFunc = Lib.load("iossound","iossound_initialize",1);
    private static var playNativeFunc = Lib.load("iossound","iossound_play",0);
    private static var stopNativeFunc = Lib.load("iossound","iossound_stop",0);
    private static var pauseNativeFunc = Lib.load("iossound","iossound_pause",0);
    private static var setLoopNativeFunc = Lib.load("iossound","iossound_setLoop",1);
    private static var setVolumeNativeFunc = Lib.load("iossound","iossound_setVolume",1);
    private static var setMuteNativeFunc = Lib.load("iossound","iossound_setMute",1);


    public var onPlaybackComplete(default,null): Signal1<Sound>;

    public function new(data: Data)
    {
        initializeNativeFunc(data);
    }

    public function play(): Void
    {
        playNativeFunc();
    }

    public function stop(): Void
    {
        stopNativeFunc();
    }

    public function pause(): Void
    {
        pauseNativeFunc();
    }

    public function mute(): Void
    {
        setMuteNativeFunc(true);
    }

    /// here you can do platform specific logic to set the sound volume
    public function set_volume(value: Float): Float
    {
        volume = value;
        setVolumeNativeFunc(volume);
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    public function set_loop(value: Bool): Bool
    {
        loop = value;
        setLoopNativeFunc(loop);
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
