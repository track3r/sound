/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;
import msignal.Signal;
import types.Data;
import cpp.Lib;
/**
 * @author kgar
 */
class Sound
{
    public var volume(default, set_volume): Float;
    public var loop(default, set_loop): Bool;
    public var length(default, null): Float;
    public var position(get_position, null): Float;
    public var loadCallback: sound.Sound -> Void;
    public var fileUrl: String;
    public var nativeSoundHandle: Dynamic;
    public var nativeSoundChannel: Dynamic;

    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","soundios_registerCallback",1);
    private static var initializeNativeFunc = Lib.load("soundios","soundios_initialize",2);
    private static var playNativeFunc = Lib.load("soundios","soundios_play",3);
    private static var stopNativeFunc = Lib.load("soundios","soundios_stop",1);
    private static var pauseNativeFunc = Lib.load("soundios","soundios_pause",2);
    private static var setVolumeNativeFunc = Lib.load("soundios","soundios_setVolume",2);
    private static var setMuteNativeFunc = Lib.load("soundios","soundios_setMute",2);

    private static var getPositionNative = Lib.load("soundios","soundios_getPosition",1);

    private var isPaused: Bool = false;

    private function new()
    {
        loop = false;
        volume = 1.0;
    }
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var pos: Int = 0;
        while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
        {
            pos++;
        }
        fileUrl = fileUrl.substr(pos);

        var soundObj: Sound = new Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;

        soundObj.loadSoundFile();
    }
    public function loadSoundFile(): Void
    {
        registerCallbackNativeFunc(onSoundLoadedCallback);
        initializeNativeFunc(fileUrl, this);
    }
    private function onSoundLoadedCallback(nativeSoundHandle: Dynamic, length: Float): Void
    {
        this.nativeSoundHandle = nativeSoundHandle;
        this.length = length;
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        if(nativeSoundHandle != null)
        {
            if(isPaused)
            {
                isPaused = false;
                pauseNativeFunc(nativeSoundChannel,false);
            }
            else
            {
                nativeSoundChannel = playNativeFunc(nativeSoundHandle, volume, loop);
            }
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
            isPaused = true;
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
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
    }
    /// get the current time of the current sound
    private function get_position(): Float
    {
        if(nativeSoundChannel != null)
        {
            return getPositionNative(nativeSoundChannel);
        }
        return 0.0;
    }
}
