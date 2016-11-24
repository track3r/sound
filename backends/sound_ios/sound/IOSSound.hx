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

import cpp.Lib;

class IOSSound
{
    private static var instance: IOSSound = null;

    public static function getInstance(): IOSSound
    {
        if (instance == null)
        {
            instance = new IOSSound();
        }
        return instance;
    }

    // Lib
    private static var nativeInitializeNativeFunc = Lib.load("soundios",    "soundios_initialize", 2);
    private static var nativeSetAllowNativePlayer = Lib.load("soundios",    "soundios_setAllowNativePlayer", 1);
    private static var nativeGetIsOtherAudioPlaying = Lib.load("soundios",  "soundios_isOtherAudioPlaying", 0);

    // BG Music
    private static var nativeBGMusicPreload = Lib.load("soundios",          "soundios_bgmusic_initialize", 2);
    private static var nativeBGMusicPlay = Lib.load("soundios",             "soundios_bgmusic_play", 3);
    private static var nativeBGMusicStop = Lib.load("soundios",             "soundios_bgmusic_stop", 1);
    private static var nativeBGMusicSetPause = Lib.load("soundios",         "soundios_bgmusic_pause", 2);
    private static var nativeBGMusicSetVolume = Lib.load("soundios",        "soundios_bgmusic_setVolume", 2);
    private static var nativeBGMusicSetMute = Lib.load("soundios",          "soundios_bgmusic_setMute", 2);
    private static var nativeBGMusicGetLength = Lib.load("soundios",        "soundios_bgmusic_getLength", 1);
    private static var nativeBGMusicGetPosition = Lib.load("soundios",      "soundios_bgmusic_getPosition", 1);

    // Sound FX
    private static var nativeSFXPreload = Lib.load("soundios",              "soundios_fx_initialize", 1);
    private static var nativeSFXPlay = Lib.load("soundios",                 "soundios_fx_play", 3);
    private static var nativeSFXStop = Lib.load("soundios",                 "soundios_fx_stop", 1);
    private static var nativeSFXSetPause = Lib.load("soundios",             "soundios_fx_pause", 2);
    private static var nativeSFXSetVolume = Lib.load("soundios",            "soundios_fx_setVolume", 2);
    private static var nativeSFXSetMute = Lib.load("soundios",              "soundios_fx_setMute", 2);

    public var onBackgroundCallback: Void -> Void;
    public var onForegroundCallback: Void -> Void;
    public var onStopCallback: Void -> Void;

    private function new()
    {
        nativeInitializeNativeFunc(onNativeBackground, onNativeForeground);
    }

    private function onNativeBackground(): Void
    {
        if (onBackgroundCallback != null)
        {
            onBackgroundCallback();
        }
    }

    private function onNativeForeground(): Void
    {
        if (onForegroundCallback != null)
        {
            onForegroundCallback();
        }
    }

    private function onNativeStop(): Void
    {
        if (onStopCallback != null)
        {
            onStopCallback();
        }
    }

    public function setAllowNativePlayer(value: Bool): Void
    {
        nativeSetAllowNativePlayer(value);
    }

    public function isOtherAudioPlaying(): Bool
    {
        return nativeGetIsOtherAudioPlaying();
    }

    public function preloadMusic(fileURL: String): Dynamic
    {
        return nativeBGMusicPreload(fileURL, onNativeStop);
    }

    public function playMusic(nativeHandle: Dynamic, volume : Float, loop: Bool): Void
    {
        nativeBGMusicPlay(nativeHandle, volume, loop);
    }

    public function stopMusic(nativeHandle: Dynamic): Void
    {
        nativeBGMusicStop(nativeHandle);
    }

    public function setMusicPause(nativeHandle: Dynamic, pause: Bool): Void
    {
        nativeBGMusicSetPause(nativeHandle, pause);
    }

    public function setMusicVolume(nativeHandle: Dynamic, volume: Float): Void
    {
        nativeBGMusicSetVolume(nativeHandle, volume);
    }

    public function setMusicMute(nativeHandle: Dynamic, mute: Bool): Void
    {
        nativeBGMusicSetMute(nativeHandle, mute);
    }

    public function getMusicLength(nativeHandle: Dynamic): Float
    {
        return nativeBGMusicGetLength(nativeHandle);
    }

    public function getMusicPosition(nativeHandle: Dynamic): Float
    {
        return nativeBGMusicGetPosition(nativeHandle);
    }

    public function preloadSFX(fileURL): Void
    {
        nativeSFXPreload(fileURL);
    }

    public function playSFX(fileURL, volume: Float, loop: Bool): Dynamic
    {
        return nativeSFXPlay(fileURL, volume, loop);
    }

    public function stopSFX(sound: Dynamic): Void
    {
        nativeSFXStop(sound);
    }

    public function setSFXPause(sound: Dynamic, pause: Bool): Void
    {
        nativeSFXSetPause(sound, pause);
    }

    public function setSFXVolume(sound: Dynamic, volume: Float): Void
    {
        nativeSFXSetVolume(sound, volume);
    }

    public function setSFXMute(sound: Dynamic, mute: Bool): Void
    {
        nativeSFXSetMute(sound, mute);
    }

}
