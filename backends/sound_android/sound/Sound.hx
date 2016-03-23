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

@:keep
class Sound
{
    public var loadCallback: Sound -> Void;
    public var volume(default, set): Float;
    public var loop(default, set): Bool;
    public var fileUrl: String;

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

    private var javaSound: Dynamic;

    public static function load(fileUrl: String, loadCallback: Sound -> Void): Void
    {
        var sound: Sound = new Sound(fileUrl);
        sound.loadCallback = loadCallback;
        sound.preload();
    }

    private function new(fileUrl: String)
    {
        var isFromAssets: Bool = false;

        if (fileUrl.indexOf(FileSystem.instance().getUrlToStaticData()) == 0)
        {
            isFromAssets = true;
            fileUrl = fileUrl.substr(FileSystem.instance().getUrlToStaticData().length);

            var pos: Int = 0;
            while (pos < fileUrl.length && fileUrl.charAt(pos) == "/")
            {
                pos++;
            }

            fileUrl = fileUrl.substr(pos);
        }

        javaSound = createNative(this, fileUrl, isFromAssets);

        volume = 1.0;
        loop = false;
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
        volume = 0.0;
    }

    public function set_volume(value: Float): Float
    {
        volume = Math.min(Math.max(value, 0.0), 1.0);
        setVolumeNative(javaSound, volume);
        return volume;
    }

    public function set_loop(value: Bool): Bool
    {
        if (loop != value)
        {
            loop = value;
            setLoopNative(javaSound, loop ? -1 : 0);
        }

        return loop;
    }

    public function onSoundLoadCompleted(): Void
    {
        if (loadCallback != null)
        {
            loadCallback(this);
        }
    }
}
