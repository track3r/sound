/**
 * @author kgar
 * @date  29/04/15 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import cpp.Lib;
import msignal.Signal.Signal1;
import types.Data;
class Music
{
    public var volume(default, set_volume): Float;
    public var loop(default, set_loop): Bool;
    public var length(get_length, null): Float;
    public var position(get_position, null): Float;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;
    public var nativeMusicHandle: Dynamic;
    public var nativeMusicChannel: Dynamic;

    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","musicios_registerCallback",1);
    private static var initializeNativeFunc = Lib.load("soundios","musicios_intialize",2);
    private static var playNativeFunc = Lib.load("soundios","musicios_play",1);
    private static var stopNativeFunc = Lib.load("soundios","musicios_stop",1);
    private static var pauseNativeFunc = Lib.load("soundios","musicios_pause",2);
    private static var setLoopNativeFunc = Lib.load("soundios","musicios_setLoop",2);
    private static var setVolumeNativeFunc = Lib.load("soundios","musicios_setVolume",2);
    private static var setMuteNativeFunc = Lib.load("soundios","musicios_setMute",2);

    public var onPlaybackComplete(default,null): Signal1<Music>;

    private function new()
    {
        loop = false;
    }
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var music: Music = new Music();
        music.loadCallback = loadCallback;
        music.fileUrl = fileUrl;
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
        initializeNativeFunc(fileUrl,this);
    }
    private function onSoundLoadedCallback(nativeSoundHandle: Dynamic): Void
    {
        this.nativeMusicHandle = nativeSoundHandle;
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        nativeMusicChannel = playNativeFunc(nativeMusicHandle);
    }

    public function stop(): Void
    {
        stopNativeFunc(nativeMusicChannel);
    }

    public function pause(): Void
    {
        pauseNativeFunc(nativeMusicChannel,true);
    }

    public function mute(): Void
    {
        setMuteNativeFunc(nativeMusicChannel, true);
    }

    /// here you can do platform specific logic to set the sound volume
    public function set_volume(value: Float): Float
    {
        volume = value;
        setVolumeNativeFunc(nativeMusicChannel, volume);
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    public function set_loop(value: Bool): Bool
    {
        loop = value;
        setLoopNativeFunc(nativeMusicChannel, loop);
        return loop;
    }

    /// get the length of the current sound
    public function get_length(): Float
    {
        return 0.0;
    }

    /// get the current time of the current sound
    public function get_position(): Float
    {
        return 0.0;
    }}
