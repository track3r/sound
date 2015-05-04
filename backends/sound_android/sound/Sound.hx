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
class Sound
{
    private static var createNative = JNI.createStaticMethod("org/haxe/duell/sound/Sound", "create",
    "(Lorg/haxe/duell/hxjni/HaxeObject;Ljava/lang/String;Z)Lorg/haxe/duell/sound/Sound;");
    private static var preloadSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "preloadSound", "(Z)V");
    private static var playSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "playSound", "()V");
    private static var stopSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "stopSound", "()V");
    private static var pauseSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "pauseSound", "()V");
    private static var setVolumeNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "setVolume", "(F)V");
    private static var setLoopNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "setLoop", "(I)V");
    private static var getDurationNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "getDuration", "()F");
    private static var getPositionNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "getPosition", "()F");

    private var javaSound: Dynamic;

    public var loadCallback: Sound -> Void;

    public var volume(default, set): Float;
    public var loop(default, set): Int;
    public var length(get, never): Float;
    public var position(get, never): Float;
    public var onPlaybackComplete(default, null): Signal1<Sound>;

    public static function load(fileUrl: String, loadCallback: Sound -> Void): Void
    {
        var sound: Sound = new Sound(fileUrl);
        sound.loadCallback = loadCallback;
        sound.preload();
    }

    private function new(fileUrl: String)
    {
        var isFromAssets: Bool = false;

        if (fileUrl.indexOf(FileSystem.instance().urlToStaticData()) == 0)
        {
            isFromAssets = true;
            fileUrl = fileUrl.substr(FileSystem.instance().urlToStaticData().length);

            var pos: Int = 0;
            while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
            {
                pos++;
            }

            fileUrl = fileUrl.substr(pos);
        }

        javaSound = createNative(this, fileUrl, isFromAssets);

        volume = 1.0;
        loop = 0;
    }

    private function preload(): Void
    {
        preloadSoundNative(javaSound, false);
    }

    public function play(): Void
    {
        playSoundNative(javaSound);
    }

    public function stop(): Void
    {
        stopSoundNative(javaSound);
    }

    public function pause(): Void
    {
        pauseSoundNative(javaSound);
    }

    public function mute(): Void
    {
        this.volume = 0;
    }

    public function set_volume(value: Float): Float
    {
        volume = Math.min(Math.max(value, 0.0), 1.0);
        setVolumeNative(javaSound, volume);
        return volume;
    }

    public function set_loop(value: Int): Int
    {
        // if it is -1, it is set as infinite loop. any other value will be clamped between 0 and the given repeat value
        var localValue: Int = value == -1 ? -1 : Std.int(Math.max(0.0, value));

        if (loop != localValue)
        {
            loop = localValue;
            setLoopNative(javaSound, loop);
        }

        return loop;
    }

    public function get_length(): Float
    {
        return getDurationNative(javaSound);
    }

    public function get_position(): Float
    {
        return getPositionNative(javaSound);
    }

    public function onSoundLoadCompleted(): Void
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
