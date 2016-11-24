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

import msignal.Signal;

using StringTools;

private enum MusicState
{
    STOPPED;
    PLAYING;
    PAUSED;
}

class Music
{
    public var volume(default, set): Float;
    public var loop(default, default): Bool;
    public var length(get, null): Float;
    public var position(get, null): Float;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;
    public var onPlaybackComplete(default, null): Signal1<Music>;

    public static var allowNativePlayer(default, set_allowNativePlayer): Bool = true;

    private var state: MusicState;
    private var onBackgroundVolume: Float = 0.0;

    private var nativeHandle: Dynamic;

    private function new()
    {
        loop = false;
        volume = 1.0;
        state = MusicState.STOPPED;
        onPlaybackComplete = new Signal1();
    }

    public static function load(fileUrl: String, loadCallback: Music -> Void): Void
    {
        var music: Music = new Music();

        music.loadCallback = loadCallback;

        /// Workaround the OALTools path resolving bug
        music.fileUrl = fileUrl.substr("file://".length);

        music.loadSoundFile();
    }

    private function loadSoundFile(): Void
    {
        IOSSound.getInstance().onBackgroundCallback = onBackground;
        IOSSound.getInstance().onStopCallback = onMusicFinishPlayingCallback;


        nativeHandle = IOSSound.getInstance().preloadMusic(fileUrl);

        if (nativeHandle != null && loadCallback != null)
        {
            loadCallback(this);
        }
    }

    private function onBackground(): Void
    {
        var oldVolume = volume;
        volume = 0.0;
        onBackgroundVolume = oldVolume;
    }

    private function onMusicFinishPlayingCallback(): Void
    {
        state = MusicState.STOPPED;
        onPlaybackComplete.dispatch(this);
    }

    public function play(): Void
    {
        if (allowNativePlayer && isNativePlayerPlaying())
        {
            stop();
            return;
        }

        if (onBackgroundVolume != 0.0)
        {
            volume = onBackgroundVolume;
        }

        if (state == MusicState.PAUSED)
        {
            IOSSound.getInstance().setMusicPause(nativeHandle, false);
        }
        else
        {
            IOSSound.getInstance().playMusic(nativeHandle, volume, loop);
        }
        state = MusicState.PLAYING;
    }

    public function stop(): Void
    {
        if (state != MusicState.STOPPED)
        {
            IOSSound.getInstance().stopMusic(nativeHandle);
            state = MusicState.STOPPED;
            onPlaybackComplete.dispatch(this);
        }
    }

    public function pause(): Void
    {
        if (state == MusicState.PLAYING)
        {
            IOSSound.getInstance().setMusicPause(nativeHandle, true);
            state = MusicState.PAUSED;
        }
    }

    public function mute(): Void
    {
        IOSSound.getInstance().setMusicMute(nativeHandle, true);
    }

    public static function isNativePlayerPlaying(): Bool
    {
        return IOSSound.getInstance().isOtherAudioPlaying();
    }

    private function set_volume(value: Float): Float
    {
        volume = value;
        onBackgroundVolume = 0.0;

        IOSSound.getInstance().setMusicVolume(nativeHandle, volume);
        return volume;
    }

    private static function set_allowNativePlayer(value: Bool): Bool
    {
        if (allowNativePlayer != value)
        {
            allowNativePlayer = value;
            IOSSound.getInstance().setAllowNativePlayer(value);
        }

        return allowNativePlayer;
    }

    private function get_length(): Float
    {
        return IOSSound.getInstance().getMusicLength(nativeHandle);
    }

    private function get_position(): Float
    {
        return IOSSound.getInstance().getMusicPosition(nativeHandle);
    }
}
