/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;

import filesystem.FileSystem;
import hxjni.JNI;
import msignal.Signal;

/**
 * @author jxav
 */
@:keep
class Music
{
    private static var createNative = JNI.createStaticMethod("org/haxe/duell/sound/Music", "create",
    "(Lorg/haxe/duell/hxjni/HaxeObject;Ljava/lang/String;)Lorg/haxe/duell/sound/Music;");
    private static var preloadMusicNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "preloadMusic", "(Z)V");
    private static var playMusicNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "playMusic", "()V");
    private static var stopMusicNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "stopMusic", "()V");
    private static var pauseMusicNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "pauseMusic", "()V");
    private static var setVolumeNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "setVolume", "(F)V");
    private static var setLoopedNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "setLooped", "(Z)V");
    private static var setAllowNativePlayerNative = JNI.createStaticMethod("org/haxe/duell/sound/Music",
    "setAllowNativePlayer", "(Z)V");
    private static var getDurationNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "getDuration", "()F");
    private static var getPositionNative = JNI.createMemberMethod("org/haxe/duell/sound/Music",
    "getPosition", "()F");

    private var javaMusic: Dynamic;

    public var loadCallback: Music -> Void;

    public var volume(default, set): Float;
    public var loop(default, set): Bool;
    public var length(get, never): Float;
    public var position(get, never): Float;
    public var onPlaybackComplete(default, null): Signal1<Music>;

    public static var allowNativePlayer(default, set_allowNativePlayer): Bool;

    public static function load(fileUrl: String, loadCallback: Music -> Void): Void
    {
        var music: Music = new Music(fileUrl);
        music.loadCallback = loadCallback;
        music.preload();
    }

    private function new(fileUrl: String)
    {
        if (fileUrl.indexOf(FileSystem.instance().getUrlToStaticData()) == 0)
        {
            fileUrl = fileUrl.substr(FileSystem.instance().getUrlToStaticData().length);

            var pos: Int = 0;
            while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
            {
                pos++;
            }

            fileUrl = fileUrl.substr(pos);
        }

        javaMusic = createNative(this, fileUrl);

        volume = 1.0;
        onPlaybackComplete = new Signal1();
    }

    private function preload(): Void
    {
        preloadMusicNative(javaMusic, false);
    }

    public function play(): Void
    {
        playMusicNative(javaMusic);
    }

    public function stop(): Void
    {
        stopMusicNative(javaMusic);
    }

    public function pause(): Void
    {
        pauseMusicNative(javaMusic);
    }

    public function mute(): Void
    {
        volume = 0;
    }

    public function set_volume(value: Float): Float
    {
        volume = Math.min(Math.max(value, 0.0), 1.0);
        setVolumeNative(javaMusic, volume);
        return volume;
    }

    public function set_loop(value: Bool): Bool
    {
        if (loop != value)
        {
            loop = value;
            setLoopedNative(javaMusic, loop);
        }

        return loop;
    }

    public static function set_allowNativePlayer(value: Bool): Bool
    {
        if (allowNativePlayer != value)
        {
            allowNativePlayer = value;
            setAllowNativePlayerNative(value);
        }

        return allowNativePlayer;
    }

    public function get_length(): Float
    {
        return getDurationNative(javaMusic);
    }

    public function get_position(): Float
    {
        return getPositionNative(javaMusic);
    }

    public function onMusicLoadCompleted(): Void
    {
        if (loadCallback != null)
        {
            loadCallback(this);
        }
    }

    public function onPlaybackCompleted(): Void
    {
        if (onPlaybackComplete != null)
        {
            onPlaybackComplete.dispatch(this);
        }
    }
}
