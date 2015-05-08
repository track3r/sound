/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;
import msignal.Signal;
import types.Data;
import cpp.Lib;
using StringTools;
/**
 * @author kgar
 */
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
    public var onPlaybackComplete(default,null): Signal1<Music>;

    ///Native function references
    private static var registerCallbackNativeFunc = Lib.load("soundios","musicios_registerCallback",2);
    private static var initializeNativeFunc = Lib.load("soundios","musicios_initialize",1);
    private static var playNativeFunc = Lib.load("soundios","musicios_play",3);
    private static var stopNativeFunc = Lib.load("soundios","musicios_stop",1);
    private static var pauseNativeFunc = Lib.load("soundios","musicios_pause",2);
    private static var setVolumeNativeFunc = Lib.load("soundios","musicios_setVolume",2);
    private static var setMuteNativeFunc = Lib.load("soundios","musicios_setMute",2);
    private static var getLengthNative = Lib.load("soundios","musicios_getLength",1);
    private static var getPositionNative = Lib.load("soundios","musicios_getPosition",1);


    private var isPaused:Bool = false;

    private function new()
    {
        loop = false;
        volume = 1.0;
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

    private function onMusicFinishPlayingCallback(filePath: String): Void
    {
        if(filePath == fileUrl)
        {
            onPlaybackComplete.dispatch(this);
        }
    }
    private function onSoundLoadedCallback(nativeMusicHandle: Dynamic): Void
    {
        this.nativeMusicHandle = nativeMusicHandle;
        if(this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }
    public function play(): Void
    {
        if(isPaused && nativeMusicChannel != null)
        {
            /// if it is paused we just resume
            isPaused = false;
            pauseNativeFunc(nativeMusicChannel, false);
        }
        else
        {
            /// otherwise we play normally
            nativeMusicChannel = playNativeFunc(fileUrl, volume, loop);
        }
    }

    public function stop(): Void
    {
        if(nativeMusicChannel != null)
        {
            stopNativeFunc(nativeMusicChannel);
        }
    }

    public function pause(): Void
    {
        if(nativeMusicChannel != null)
        {
            isPaused = true;
            pauseNativeFunc(nativeMusicChannel, true);
        }
    }

    public function mute(): Void
    {
        if(nativeMusicChannel != null)
        {
            setMuteNativeFunc(nativeMusicChannel, true);
        }
    }

    /// here you can do platform specific logic to set the sound volume
    private function set_volume(value: Float): Float
    {
        volume = value;
        if(nativeMusicChannel != null)
        {
            setVolumeNativeFunc(nativeMusicChannel, volume);
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
        if(nativeMusicChannel != null)
        {
            return getLengthNative(nativeMusicChannel);
        }
        return 0.0;
    }

    /// get the current time of the current sound
    private function get_position(): Float
    {
        if(nativeMusicChannel != null)
        {
            return getPositionNative(nativeMusicChannel);
        }
        return 0.0;
    }
}
