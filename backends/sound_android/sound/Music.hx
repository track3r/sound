/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package sound;

import filesystem.FileSystem;
import hxjni.JNI;
import msignal.Signal;

@:keep
class Music
{
    public var volume(default, set): Float;
    public var loop(default, set): Bool;
    public var length(get, null): Float;
    public var position(get, null): Float;
    public var loadCallback: Music -> Void;
    public var fileUrl: String;
    public var onPlaybackComplete(default, null): Signal1<Music>;

    public static var allowNativePlayer(default, set_allowNativePlayer): Bool;

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
